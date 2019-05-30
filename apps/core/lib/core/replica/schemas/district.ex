defmodule Core.Replica.Region do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "regions" do
    field(:name, :string)
    field(:koatuu, :string)

    timestamps(type: :utc_datetime)

    belongs_to(:area, Core.Replica.Area, type: Ecto.UUID)

    has_many(:settlements, Core.Replica.Settlement)
  end
end
