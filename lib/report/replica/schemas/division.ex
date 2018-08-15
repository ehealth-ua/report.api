defmodule Report.Replica.Division do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "divisions" do
    field(:email, :string)
    field(:name, :string, null: false)
    field(:external_id, :string)
    field(:phones, {:array, :map}, null: false)
    field(:mountain_group, :boolean)
    field(:type, :string, null: false)
    field(:status, :string, null: false)
    field(:is_active, :boolean, default: false)
    field(:location, Geo.Geometry)
    field(:working_hours, :map)

    belongs_to(:legal_entity, Report.Replica.LegalEntity, type: Ecto.UUID)
    has_many(:addresses, Report.Replica.DivisionAddress, foreign_key: :division_id)

    timestamps(type: :utc_datetime)
  end
end
