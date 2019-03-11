defmodule Core.Replica.Region do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "regions" do
    field(:name, :string)
    field(:koatuu, :string)
    timestamps(type: :utc_datetime)

    has_many(:districts, Core.Replica.District)
  end
end
