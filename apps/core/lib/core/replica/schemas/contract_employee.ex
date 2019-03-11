defmodule Core.Replica.ContractEmployee do
  @moduledoc false

  use Ecto.Schema
  alias Core.Replica.Contract
  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "contract_employees" do
    field(:employee_id, UUID)
    field(:staff_units, :float)
    field(:declaration_limit, :integer)
    field(:division_id, UUID)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:inserted_by, UUID)
    field(:updated_by, UUID)

    belongs_to(:contract, Contract, type: UUID)

    timestamps(type: :utc_datetime)
  end
end
