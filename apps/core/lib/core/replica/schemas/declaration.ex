defmodule Core.Replica.Declaration do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "declarations" do
    field(:employee_id, Ecto.UUID)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:status, :string)
    field(:signed_at, :utc_datetime)
    field(:created_by, Ecto.UUID)
    field(:updated_by, Ecto.UUID)
    field(:is_active, :boolean, default: false)
    field(:scope, :string)
    field(:declaration_request_id, Ecto.UUID)
    field(:seed, :string)

    belongs_to(:division, Core.Replica.Division, type: Ecto.UUID)
    belongs_to(:person, Core.Replica.Person, type: Ecto.UUID)
    belongs_to(:legal_entity, Core.Replica.LegalEntity, type: Ecto.UUID)

    timestamps(type: :utc_datetime)
  end
end
