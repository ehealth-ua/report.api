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

  def start_link(offset) do
    GenStage.start_link(__MODULE__, offset, name: __MODULE__)
  end

  def init(offset) do
    {:producer, offset}
  end

  def handle_demand(demand, offset) when demand > 0 do
    case Cache.get_billing_date() do
      {:ok, billing_date} when not is_nil(billing_date) ->
        contract_employees = contract_employees_query(billing_date, offset, demand)
        contract_employees_count = Enum.count(contract_employees)

        if contract_employees_count == 0 do
          {:noreply, [nil], 0}
        else
          {:noreply, contract_employees, offset + contract_employees_count}
        end

      _ ->
        {:noreply, [nil], 0}
    end
  end

  defp contract_employees_query(billing_date, offset, limit) do
    billing_date
    |> Capitation.get_contracts_query()
    |> join(
      :inner,
      [c],
      ce in ContractEmployee,
      c.id == ce.contract_id and fragment("?::date < ?", ce.start_date, ^billing_date) and
        fragment("(? is null or ?::date >= ?)", ce.end_date, ce.end_date, ^billing_date)
    )
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
      WHERE inserted_at::date < ?::date
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
