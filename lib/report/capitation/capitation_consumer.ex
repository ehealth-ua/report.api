defmodule Report.Capitation.CapitationConsumer do
  @moduledoc false

  use GenStage
  use Confex, otp_app: :report_api
  alias Report.Capitation.Cache
  alias Report.Capitation.CapitationReportDetail
  alias Report.Capitation.CapitationReportError

  @media_storage_api Application.get_env(:report_api, :api_resolvers)[:media_storage]

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(_) do
    {:consumer, %{}}
  end

  @impl true
  def handle_subscribe(:producer, opts, from, producers) do
    # We will only allow max_demand events every 5000 milliseconds
    pending = opts[:max_demand] || 5
    # interval = opts[:interval] || 5000

    # Register the producer in the state
    producers = Map.put(producers, from, pending)
    # Ask for the pending events and schedule the next time around
    producers = ask_and_schedule(producers, from)

    # Returns manual as we want control over the demand
    {:manual, producers}
  end

  @impl true
  def handle_cancel(_, from, producers) do
    # Remove the producers from the map on unsubscribe
    {:noreply, [], Map.delete(producers, from)}
  end

  @impl true
  @doc "Time to stop consumer and dump events to storage"
  def handle_events([nil], _from, producers) do
    Cache.dump()
    {:stop, :normal, producers}
  end

  def handle_events(contract_employees, from, producers) do
    # Bump the amount of pending events for the given producer
    producers =
      Map.update!(producers, from, fn pending ->
        pending + length(contract_employees)
      end)

    ets_pid = Cache.get_ets()
    errors_pid = Cache.get_errors_ets()
    Enum.each(contract_employees, &process_contract_employee(&1, ets_pid, errors_pid))
    {:noreply, [], producers}
  end

  defp process_contract_employee(contract_employee, ets_pid, errors_pid) do
    %{
      id: id,
      legal_entity_id: legal_entity_id,
      birth_date: birth_date,
      contract_id: contract_id,
      mountain_group: mountain_group,
      seed: seed,
      edrpou: edrpou
    } = contract_employee

    age_group = get_age_group(birth_date)

    key =
      :md5
      |> :crypto.hash("#{legal_entity_id}:#{age_group}:#{contract_id}:#{mountain_group}")
      |> Base.encode64()

    if config()[:capitation_validate_signature] do
      with {_, {:ok, %{"data" => %{"secret_url" => url}}}} <- {:secret_url, get_signed_declaration_url(id)},
           {_, {:ok, %{"data" => %{"is_valid" => true}}}} <- {:signature, validate_declaration(seed, edrpou, url)} do
        :ets.update_counter(ets_pid, key, {2, 1}, {key, 0, legal_entity_id, age_group, contract_id, mountain_group})
      else
        {:secret_url, _} ->
          :ets.insert(errors_pid, {key, id, CapitationReportError.action(:validation), "Can't generate secret_url"})

        {:signature, _} ->
          :ets.insert(errors_pid, {key, id, CapitationReportError.action(:validation), "Invalid signed content"})
      end
    else
      :ets.update_counter(ets_pid, key, {2, 1}, {key, 0, legal_entity_id, age_group, contract_id, mountain_group})
    end
  end

  defp get_age_group(birth_date) do
    %{year: today_year} = Date.utc_today()
    %{year: year} = birth_date

    cond do
      today_year - year <= 5 -> CapitationReportDetail.age_group(:"0-5")
      today_year - year <= 17 -> CapitationReportDetail.age_group(:"6-17")
      today_year - year <= 39 -> CapitationReportDetail.age_group(:"18-39")
      today_year - year <= 65 -> CapitationReportDetail.age_group(:"40-65")
      true -> CapitationReportDetail.age_group(:"65+")
    end
  end

  defp get_signed_declaration_url(id) do
    declarations_bucket = Confex.fetch_env!(:report_api, Report.MediaStorage)[:declarations_bucket]
    @media_storage_api.create_signed_url("GET", declarations_bucket, "signed_content", id)
  end

  defp validate_declaration(seed, edrpou, url) do
    @media_storage_api.validate_signed_entity(
      %{
        "url" => url,
        "rules" => [
          %{
            "field" => ["legal_entity", "edrpou"],
            "type" => "eq",
            "value" => edrpou
          },
          %{
            "field" => ["seed"],
            "type" => "eq",
            "value" => seed
          }
        ]
      },
      retry: 5,
      timeout: 1000
    )
  end

  @impl true
  def handle_info({:ask, from}, producers) do
    # This callback is invoked by the Process.send_after/3 message below.
    {:noreply, [], ask_and_schedule(producers, from)}
  end

  defp ask_and_schedule(producers, from) do
    case producers do
      %{^from => pending} ->
        # Ask for any pending events
        GenStage.ask(from, pending)
        # And let's check again after interval
        Process.send_after(self(), {:ask, from}, 10)
        # Finally, reset pending events to 0
        Map.put(producers, from, 0)

      %{} ->
        producers
    end
  end
end
