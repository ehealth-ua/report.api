defmodule Core.Replica.INNMDosageIngredient do
  @moduledoc false

  use Ecto.Schema
  alias Core.Replica.INNM
  alias Core.Replica.Medication

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "ingredients" do
    field(:dosage, :map)
    field(:is_primary, :boolean, default: false)

    belongs_to(:innm_dosage, Medication, type: Ecto.UUID, foreign_key: :parent_id)
    belongs_to(:innm, INNM, type: Ecto.UUID, foreign_key: :innm_child_id)

    timestamps()
  end
end
