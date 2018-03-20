defmodule Report.Replica.Street do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "streets" do
    field(:name, :string)
    field(:type, :string)

    timestamps()

    has_many(:aliases, Report.Replica.StreetsAliases)

    belongs_to(:settlement, Report.Replica.Settlement, type: Ecto.UUID)
  end
end
