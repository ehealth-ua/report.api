defmodule Report.Capitation.Cache do
  @moduledoc false

  use GenServer
  alias Report.Capitation
  alias Report.Capitation.CapitationReportDetail
  alias Report.Capitation.CapitationReportError
  alias Report.Repo

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    capitation_pid = :ets.new(:capitation, [:set, :public])
    contractor_employees_pid = :ets.new(:contractor_employees, [:set, :public])
    error_pid = :ets.new(:capitation_errors, [:set, :public])
    ids_pid = :ets.new(:capitation_ids, [:set, :public])

    {:ok,
     %{
       ets: capitation_pid,
       contractor_employees_ets: contractor_employees_pid,
       errors_ets: error_pid,
       ids_ets: ids_pid
     }}
  end

  @impl true
  def handle_call({:billing_date, billing_date}, _from, state) do
    {:reply, :ok, Map.put(state, :billing_date, billing_date)}
  end

  @impl true
  def handle_call(:billing_date, _from, %{billing_date: billing_date} = state) do
    {:reply, {:ok, billing_date}, state}
  end

  @impl true
  def handle_call({:report_id, report_id}, _from, state) do
    {:reply, :ok, Map.put(state, :report_id, report_id)}
  end

  @impl true
  def handle_call(:report_id, _from, %{report_id: report_id} = state) do
    {:reply, {:ok, report_id}, state}
  end

  @impl true
  def handle_call(:ets, _from, %{ets: ets} = state) do
    {:reply, ets, state}
  end

  @impl true
  def handle_call(:errors_ets, _from, %{errors_ets: ets} = state) do
    {:reply, ets, state}
  end

  @impl true
  def handle_call(:contractor_employees_ets, _from, %{contractor_employees_ets: ets} = state) do
    {:reply, ets, state}
  end

  @impl true
  def handle_call(:ids_ets, _from, %{ids_ets: ets} = state) do
    {:reply, ets, state}
  end

  @impl true
  def handle_cast(:dump, %{ets: pid, errors_ets: errors_pid, report_id: report_id} = state) do
    # Save successfull details
    pid
    |> get_key_stream()
    |> Stream.each(fn key ->
      [{_, declaration_count, legal_entity_id, age_group, contract_id, mountain_group}] = :ets.lookup(pid, key)

      %CapitationReportDetail{}
      |> Capitation.changeset(%{
        capitation_report_id: report_id,
        declaration_count: declaration_count,
        legal_entity_id: legal_entity_id,
        age_group: age_group,
        contract_id: contract_id,
        mountain_group: mountain_group
      })
      |> Repo.insert!()
    end)
    |> Stream.run()

    # Save errors
    errors_pid
    |> get_key_stream
    |> Stream.each(fn key ->
      [{_, declaration_id, action, message}] = :ets.lookup(errors_pid, key)

      %CapitationReportError{}
      |> Capitation.changeset(%{
        capitation_report_id: report_id,
        declaration_id: declaration_id,
        action: action,
        message: message
      })
      |> Repo.insert!()
    end)
    |> Stream.run()

    # Drop capitation supervision tree
    [{supervisor_pid, _}] = Registry.lookup(:capitation_registry, "supervisor")
    Supervisor.stop(supervisor_pid, :normal, 5_000)

    {:noreply, state}
  end

  def get_billing_date do
    GenServer.call(__MODULE__, :billing_date)
  end

  def set_billing_date(billing_date) do
    GenServer.call(__MODULE__, {:billing_date, billing_date})
  end

  def get_report_id do
    GenServer.call(__MODULE__, :report_id)
  end

  def set_report_id(report_id) do
    GenServer.call(__MODULE__, {:report_id, report_id})
  end

  def get_ets do
    GenServer.call(__MODULE__, :ets)
  end

  def get_contractor_employees_ets do
    GenServer.call(__MODULE__, :contractor_employees_ets)
  end

  def get_errors_ets do
    GenServer.call(__MODULE__, :errors_ets)
  end

  def get_ids_ets do
    GenServer.call(__MODULE__, :ids_ets)
  end

  def dump do
    GenServer.cast(__MODULE__, :dump)
  end

  def get_key_stream(pid) do
    Stream.resource(
      fn -> :ets.first(pid) end,
      fn
        :"$end_of_table" -> {:halt, nil}
        previous_key -> {[previous_key], :ets.next(pid, previous_key)}
      end,
      fn _ -> :ok end
    )
  end
end
