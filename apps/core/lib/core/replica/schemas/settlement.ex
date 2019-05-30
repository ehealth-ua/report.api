defmodule Core.Replica.Settlement do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "settlements" do
    field(:type, :string)
    field(:name, :string)
    field(:mountain_group, :boolean)
    field(:koatuu, :string)

    timestamps(type: :utc_datetime)

    belongs_to(:area, Core.Replica.Area, type: Ecto.UUID)
    belongs_to(:region, Core.Replica.Region, type: Ecto.UUID)
    belongs_to(:parent_settlement, Core.Replica.Settlement, type: Ecto.UUID)
  end
end
