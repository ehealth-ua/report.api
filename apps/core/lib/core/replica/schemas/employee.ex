defmodule Core.Replica.Employee do
  @moduledoc false

  use Ecto.Schema

  @type_owner "OWNER"
  @type_pharmacy_owner "PHARMACY_OWNER"

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "employees" do
    field(:employee_type, :string)
    field(:is_active, :boolean, default: false)
    field(:position, :string)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:status, :string)
    field(:status_reason, :string)
    field(:speciality, :map)
    field(:updated_by, Ecto.UUID)
    field(:inserted_by, Ecto.UUID)

    belongs_to(:party, Core.Replica.Party, type: Ecto.UUID)
    belongs_to(:division, Core.Replica.Division, type: Ecto.UUID)
    belongs_to(:legal_entity, Core.Replica.LegalEntity, type: Ecto.UUID)

    has_one(:doctor, Core.Replica.EmployeeDoctor)
    has_many(:declarations, Core.Replica.Declaration)

    timestamps(type: :utc_datetime)
  end

  def type(:owner), do: @type_owner
  def type(:pharmacy_owner), do: @type_pharmacy_owner
end
