defmodule Core.Replica.Area do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "areas" do
    field(:name, :string)
    field(:koatuu, :string)
    timestamps(type: :utc_datetime)

    has_many(:regions, Core.Replica.Region)
  end
end
