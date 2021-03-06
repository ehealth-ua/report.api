defmodule Core.Replica.Medication do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "medications" do
    field(:name, :string)
    field(:form, :string)
    field(:type, :string)
    field(:code_atc, {:array, :string})
    field(:certificate, :string)
    field(:certificate_expired_at, :date)
    field(:container, :map)
    field(:manufacturer, :map)
    field(:package_qty, :integer)
    field(:package_min_qty, :integer)
    field(:is_active, :boolean, default: true)
    field(:inserted_by, Ecto.UUID)
    field(:updated_by, Ecto.UUID)
    field(:daily_dosage, :float)

    timestamps(type: :utc_datetime)
  end
end
