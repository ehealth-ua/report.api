defmodule Core.Replica.Person do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "persons" do
    field(:birth_date, :date)
    field(:death_date, :date)
    field(:addresses, {:array, :map})
    timestamps(type: :utc_datetime)
  end
end
