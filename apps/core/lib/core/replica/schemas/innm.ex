defmodule Core.Replica.INNM do
  @moduledoc false

  use Ecto.Schema
  alias Core.Replica.INNMDosageIngredient

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "innms" do
    field(:sctid, :string)
    field(:name, :string)
    field(:name_original, :string)
    field(:is_active, :boolean, default: true)
    field(:inserted_by, Ecto.UUID)
    field(:updated_by, Ecto.UUID)

    has_many(:ingredients, INNMDosageIngredient, foreign_key: :innm_child_id)

    timestamps(type: :utc_datetime)
  end
end
