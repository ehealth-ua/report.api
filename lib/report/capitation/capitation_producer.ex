defmodule Report.Capitation.CapitationProducer do
  @moduledoc """
  Contract producer
  """

  use GenStage
  alias Report.Capitation.Cache
  alias Report.Replica.Contract
  alias Report.Replica.ContractEmployee
  alias Report.Replica.Division
  alias Report.Replica.Declaration
  alias Report.Replica.DeclarationStatusHistory
  alias Report.Replica.LegalEntity
  alias Report.Replica.Person
  alias Report.Repo
  import Ecto.Query

  @status_verified Contract.status(:verified)

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
    Contract
    |> where([c], c.start_date < ^billing_date and c.end_date >= ^billing_date and c.status == @status_verified)
    |> join(
      :left,
      [c],
      ce in ContractEmployee,
      c.id == ce.contract_id and fragment("?::date < ?", ce.start_date, ^billing_date) and
        fragment("? is null or ?::date >= ?", ce.end_date, ce.end_date, ^billing_date)
    )
    |> join(:left, [_, ce], d in Declaration, d.employee_id == ce.employee_id and d.division_id == ce.division_id)
    |> join(:left, [_, _, d], p in Person, p.id == d.person_id)
    |> join(:left, [_, ce], dv in Division, dv.id == ce.division_id)
    |> join(:left, [_, _, d], le in LegalEntity, le.id == d.legal_entity_id)
    |> join(
      :left,
      [_, _, d, _],
      dsh in DeclarationStatusHistory,
      dsh.declaration_id == d.id and fragment("?::date <= ?", dsh.inserted_at, ^billing_date)
    )
    |> select([c, _, d, p, dv, le], %{
      id: d.id,
      contract_id: c.id,
      legal_entity_id: c.contractor_legal_entity_id,
      mountain_group: dv.mountain_group,
      birth_date: p.birth_date,
      seed: d.seed,
      edrpou: le.edrpou
    })
    |> distinct([..., dsh], dsh.declaration_id)
    |> order_by([..., dsh], desc: dsh.inserted_at)
    |> offset(^offset)
    |> limit(^limit)
    |> Repo.all()
  end
end
