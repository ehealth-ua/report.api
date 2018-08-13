defmodule Report.Capitation.CapitationProducer do
  @moduledoc """
  Contract producer
  """

  use GenStage
  alias Report.Capitation
  alias Report.Capitation.Cache
  alias Report.Replica.ContractEmployee
  alias Report.Replica.Declaration
  alias Report.Replica.Division
  alias Report.Replica.LegalEntity
  alias Report.Replica.Person
  alias Report.Repo
  import Ecto.Query

  def start_link(index) do
    GenStage.start_link(__MODULE__, index, name: __MODULE__)
  end

  def init(index) do
    {:producer, %{index: index, offset: 0}}
  end

  def handle_demand(demand, state) when demand > 0 do
    case Cache.get_billing_date() do
      {:ok, billing_date} when not is_nil(billing_date) ->
        index = state.index
        offset = state.offset
        {index, offset, contract_employees} = get_contract_employees(index, billing_date, offset, demand)

        case contract_employees do
          [nil] ->
            {:noreply, [nil], %{index: 0, offset: 0}}

          _ ->
            {:noreply, contract_employees, get_new_state(state, index, offset, Enum.count(contract_employees), demand)}
        end

      _ ->
        {:noreply, [nil], %{index: 0, offset: 0}}
    end
  end

  defp get_new_state(state, index, _, data_length, data_demand) when data_length < data_demand do
    state
    |> Map.put(:index, index + 1)
    |> Map.put(:offset, 0)
  end

  defp get_new_state(state, index, offset, data_length, _) do
    state
    |> Map.put(:index, index)
    |> Map.put(:offset, offset + data_length)
  end

  defp get_contract_employees(index, billing_date, offset, limit) do
    ids_ets_pid = Cache.get_ids_ets()

    key =
      ids_ets_pid
      |> Cache.get_key_stream()
      |> Enum.at(index)

    if is_nil(key) do
      {index, offset, [nil]}
    else
      [{_, contract_id, contract_employee_id}] = :ets.lookup(ids_ets_pid, key)
      contract_employees = contract_employees_query(billing_date, contract_id, contract_employee_id, offset, limit)

      if Enum.empty?(contract_employees) do
        get_contract_employees(index + 1, billing_date, 0, limit)
      else
        {index, offset, contract_employees}
      end
    end
  end

  defp contract_employees_query(billing_date, contract_id, contract_employee_id, offset, limit) do
    contract_id
    |> Capitation.get_contracts_query_by_id()
    |> Capitation.get_contract_employees_query_by_id(contract_employee_id)
    |> join(:inner, [_, ce], d in Declaration, d.employee_id == ce.employee_id and d.division_id == ce.division_id)
    |> join(:inner, [_, _, d], p in Person, p.id == d.person_id)
    |> join(:inner, [_, ce, d], dv in Division, dv.id == d.division_id)
    |> join(:inner, [_, _, d], le in LegalEntity, le.id == d.legal_entity_id)
    |> join(
      :left,
      [_, _, d, _],
      dsh in fragment(
        "
      SELECT DISTINCT declaration_id, last_value(status) OVER (
          PARTITION BY declaration_id ORDER BY inserted_at
          RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
      ) as status
      FROM declarations_status_hstr
      WHERE inserted_at < ?::date
      ",
        ^billing_date
      ),
      dsh.declaration_id == d.id
    )
    |> select([c, ce, d, p, dv, le, dsh], %{
      id: d.id,
      contractor_employee_id: ce.id,
      declaration_limit: ce.declaration_limit,
      contract_id: c.id,
      legal_entity_id: c.contractor_legal_entity_id,
      mountain_group: dv.mountain_group,
      birth_date: p.birth_date,
      seed: d.seed,
      edrpou: le.edrpou,
      history_status: dsh.status
    })
    |> subquery()
    |> where([a], a.history_status == "active")
    |> offset(^offset)
    |> limit(^limit)
    |> Repo.all()
  end
end
