defmodule Core.Replica.Division do
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
    field(:location, Geo.PostGIS.Geometry)
    field(:working_hours, :map)
    field(:dls_id, :string)
    field(:dls_verified, :boolean)
    field(:mobile_phone, :string)
    field(:land_line_phone, :string)

    belongs_to(:legal_entity, Core.Replica.LegalEntity, type: Ecto.UUID)
    has_many(:addresses, Core.Replica.DivisionAddress, foreign_key: :division_id)

    timestamps(type: :utc_datetime)
  end
end
