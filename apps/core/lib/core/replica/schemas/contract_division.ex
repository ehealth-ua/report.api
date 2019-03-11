defmodule Core.Replica.ContractDivision do
  @moduledoc false

  use Ecto.Schema
  alias Core.Replica.Contract
  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "contract_divisions" do
    field(:division_id, UUID)
    field(:inserted_by, UUID)
    field(:updated_by, UUID)

    belongs_to(:contract, Contract, type: UUID)

    timestamps(type: :utc_datetime)
  end
end
