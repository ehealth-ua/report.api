defmodule Core.Replica.Street do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "streets" do
    field(:name, :string)
    field(:type, :string)

    timestamps(type: :utc_datetime)

    has_many(:aliases, Core.Replica.StreetsAliases)

    belongs_to(:settlement, Core.Replica.Settlement, type: Ecto.UUID)
  end
end
