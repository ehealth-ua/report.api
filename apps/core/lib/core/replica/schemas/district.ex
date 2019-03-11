defmodule Core.Replica.District do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "districts" do
    field(:name, :string)
    field(:koatuu, :string)

    timestamps(type: :utc_datetime)

    belongs_to(:region, Core.Replica.Region, type: Ecto.UUID)

    has_many(:settlements, Core.Replica.Settlement)
  end
end
