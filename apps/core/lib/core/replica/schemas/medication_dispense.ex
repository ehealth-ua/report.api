defmodule Core.Replica.MedicationDispense do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "medication_dispenses" do
    field(:medication_request_id, Ecto.UUID)
    field(:dispensed_at, :date)
    field(:party_id, Ecto.UUID)
    field(:legal_entity_id, Ecto.UUID)
    field(:division_id, Ecto.UUID)
    field(:medical_program_id, Ecto.UUID)
    field(:payment_id, :string)
    field(:payment_amount, :float)
    field(:status, :string)
    field(:is_active, :boolean)
    field(:inserted_by, Ecto.UUID)
    field(:updated_by, Ecto.UUID)
    field(:dispensed_by, :string)

    has_many(:details, Core.Replica.MedicationDispense.Details)
    belongs_to(:medication_request, Core.Replica.MedicationRequest, define_field: false)
    belongs_to(:party, Core.Replica.Party, define_field: false)
    belongs_to(:division, Core.Replica.Division, define_field: false)
    belongs_to(:legal_entity, Core.Replica.LegalEntity, define_field: false)
    belongs_to(:medical_program, Core.Replica.MedicalProgram, define_field: false)

    timestamps(type: :utc_datetime)
  end
end
