defmodule Capitation.CapitationProducer do
  @moduledoc """
  Contract producer
  """

  use GenStage
  alias Capitation.API
  alias Capitation.Cache
  alias Core.Replica.Declaration
  alias Core.Replica.Division
  alias Core.Replica.LegalEntity
  alias Core.Replica.Person
  alias Core.Repo
  import Ecto.Query

  def start_link(index) do
    GenStage.start_link(__MODULE__, index, name: :capitation_producer)
  end

  def init(index) do
    {:producer, %{index: index, offset: 0}}
  end

  def handle_demand(demand, state) when demand > 0 do
    case Cache.get_billing_date() do
      {:ok, billing_date} when not is_nil(billing_date) ->
        index = state.index
        offset = state.offset
        {index, offset, contract_employees} = get_contract_employees(index, offset, demand)

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

  defp get_contract_employees(index, offset, limit) do
    ids_ets_pid = Cache.get_ids_ets()

    key =
      ids_ets_pid
      |> Cache.get_key_stream()
      |> Enum.at(index)

    if is_nil(key) do
      {index, offset, [nil]}
    else
      [{_, contract_id, contract_employee_id}] = :ets.lookup(ids_ets_pid, key)
      contract_employees = contract_employees_query(contract_id, contract_employee_id, offset, limit)

      if Enum.empty?(contract_employees) do
        get_contract_employees(index + 1, 0, limit)
      else
        {index, offset, contract_employees}
      end
    end
  end

  defp contract_employees_query(contract_id, contract_employee_id, offset, limit) do
    contract_id
    |> API.get_contracts_query_by_id()
    |> API.get_contract_employees_query_by_id(contract_employee_id)
    |> join(:inner, [_, ce], d in Declaration, on: d.employee_id == ce.employee_id and d.division_id == ce.division_id)
    |> join(:inner, [_, _, d], p in Person, on: p.id == d.person_id)
    |> join(:inner, [_, ce, d], dv in Division, on: dv.id == d.division_id)
    |> join(:inner, [_, _, d], le in LegalEntity, on: le.id == d.legal_entity_id)
    |> join(
      :left,
      [_, _, d, _],
      dsh in fragment("SELECT * FROM mv_declarations_status_hstr"),
      on: dsh.declaration_id == d.id
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
    |> where([a], a.history_status == "active" or is_nil(a.history_status))
    |> offset(^offset)
    |> limit(^limit)
    |> Repo.all(timeout: :infinity)
  end
end
