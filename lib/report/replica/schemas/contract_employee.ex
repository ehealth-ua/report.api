defmodule Report.Replica.ContractEmployee do
  @moduledoc false

  use Ecto.Schema
  alias Ecto.UUID
  alias Report.Replica.Contract

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "contract_employees" do
    field(:employee_id, UUID)
    field(:staff_units, :float)
    field(:declaration_limit, :integer)
    field(:division_id, UUID)
    field(:start_date, :naive_datetime)
    field(:end_date, :naive_datetime)
    field(:inserted_by, UUID)
    field(:updated_by, UUID)

    belongs_to(:contract, Contract, type: UUID)

    timestamps()
  end
end
