defmodule Capitation.API do
  @moduledoc false

  alias Capitation.Cache
  alias Capitation.CapitationConsumer
  alias Core.Capitation
  alias Core.CapitationReport
  alias Core.CapitationReportDetail
  alias Core.Replica.Contract
  alias Core.Replica.ContractEmployee
  alias Core.Repo
  alias Ecto.Adapters.SQL
  import Ecto.Query
  require Logger

  def run do
    billing_date = Map.put(Date.utc_today(), :day, 1)
    Cache.set_billing_date(billing_date)

    with {:ok, report} <-
           %CapitationReport{}
           |> Capitation.changeset(%{billing_date: billing_date})
           |> Repo.insert() do
      Cache.set_report_id(report.id)
      producer_pid = Process.whereis(:capitation_producer)
      consumer_pid = Process.whereis(:capitation_consumer)

      age_groups = [
        CapitationReportDetail.age_group(:"0-5"),
        CapitationReportDetail.age_group(:"6-17"),
        CapitationReportDetail.age_group(:"18-39"),
        CapitationReportDetail.age_group(:"40-65"),
        CapitationReportDetail.age_group(:"65+")
      ]

      case create_materialized_view(billing_date) do
        :ok ->
          ets_pid = Cache.get_ets()

          billing_date
          |> get_contracts_query()
          |> Repo.all()
          |> Enum.each(fn %Contract{id: id, contractor_legal_entity_id: legal_entity_id} ->
            for age_group <- age_groups do
              for mountain_group <- [true, false] do
                key = CapitationConsumer.get_key(id, legal_entity_id, age_group, mountain_group)
                :ets.insert(ets_pid, {key, 0, legal_entity_id, age_group, id, mountain_group})
              end
            end
          end)

          ids_ets_pid = Cache.get_ids_ets()

          billing_date
          |> get_contracts_query()
          |> get_contract_employees_query(billing_date)
          |> select([c, ce], {c.id, ce.id})
          |> Repo.all()
          |> Enum.each(fn {contract_id, contract_employee_id} ->
            key = contract_id <> "_" <> contract_employee_id
            :ets.insert(ids_ets_pid, {key, contract_id, contract_employee_id})
          end)

          GenStage.sync_subscribe(
            consumer_pid,
            to: producer_pid,
            max_demand: CapitationConsumer.config()[:max_demand]
          )

        {:error, error} ->
          Cache.set_report_id(nil)
          Logger.error(fn -> "Error during materialized view creation: #{error}" end)
      end
    end
  end

  def get_contracts_query(billing_date) do
    Contract
    |> where(
      [c],
      c.start_date < ^billing_date and c.end_date >= ^billing_date
    )
    |> where([c], c.status == ^Contract.status(:verified))
    |> where([c], c.is_suspended == false)
    |> where([c], c.type == "CAPITATION")
  end

  def get_contracts_query_by_id(contract_id) do
    where(Contract, [c], c.id == ^contract_id)
  end

  def get_contract_employees_query(query, billing_date) do
    join(
      query,
      :inner,
      [c],
      ce in ContractEmployee,
      on:
        c.id == ce.contract_id and fragment("?::date < ?", ce.start_date, ^billing_date) and
          fragment("(? is null or ?::date >= ?)", ce.end_date, ce.end_date, ^billing_date)
    )
  end

  def get_contract_employees_query_by_id(query, contract_employee_id) do
    join(query, :inner, [c], ce in ContractEmployee, on: c.id == ce.contract_id and ce.id == ^contract_employee_id)
  end

  defp create_materialized_view(billing_date) do
    queries = [
      "DROP MATERIALIZED VIEW IF EXISTS mv_declarations_status_hstr;",
      "CREATE MATERIALIZED VIEW mv_declarations_status_hstr
      AS (
        SELECT distinct
          declaration_id,
          last_value(status) OVER (
            PARTITION BY declaration_id ORDER BY inserted_at
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
          ) as status
        FROM declarations_status_hstr
        WHERE inserted_at < '#{Date.to_string(billing_date)}');",
      "CREATE INDEX mv_declarations_status_hstr_declaration_id_index
        ON mv_declarations_status_hstr (declaration_id);"
    ]

    Enum.reduce_while(queries, :ok, fn query, acc ->
      case SQL.query(Repo, query, [], timeout: :infinity) do
        {:ok, _} ->
          {:cont, acc}

        {:error, %Postgrex.Error{postgres: %{message: message}}} ->
          {:halt, {:error, message}}
      end
    end)
  end
end
