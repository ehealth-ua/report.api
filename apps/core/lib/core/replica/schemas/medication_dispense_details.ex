defmodule Core.Replica.MedicationDispense.Details do
  @moduledoc false

  use Ecto.Schema

  schema "medication_dispense_details" do
    field(:medication_id, Ecto.UUID)
    field(:medication_qty, :float)
    field(:sell_price, :float)
    field(:reimbursement_amount, :float)
    field(:medication_dispense_id, Ecto.UUID)
    field(:sell_amount, :float)
    field(:discount_amount, :float)

    belongs_to(:medication_dispense, Core.Replica.MedicationDispense, define_field: false)
    belongs_to(:medication, Core.Replica.Medication, define_field: false)
  end
end
