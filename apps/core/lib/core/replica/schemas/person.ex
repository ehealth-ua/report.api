defmodule Core.Replica.Person do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "persons" do
    field(:birth_date, :date)
    field(:death_date, :date)
    field(:addresses, {:array, :map})
    field(:gender, :string)
    field(:is_active, :boolean)
    field(:status, :string)
    timestamps(type: :utc_datetime)
  end
end
