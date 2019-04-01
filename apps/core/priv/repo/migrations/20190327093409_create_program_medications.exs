defmodule Core.Repo.Migrations.CreateProgramMedications do
  use Ecto.Migration

  def change do
    create table(:program_medications, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:reimbursement, :map)
      add(:reimbursement_type, :string)
      add(:reimbursement_amount, :numeric)
      add(:is_active, :boolean)
      add(:medication_request_allowed, :boolean)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)
      add(:medication_id, :uuid)
      add(:medical_program_id, :uuid)
      add(:wholesale_price, :float)
      add(:consumer_price, :float)
      add(:reimbursement_daily_dosage, :float)
      add(:estimated_payment_amount, :float)

      timestamps(type: :utc_datetime_usec)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_program_medication_reimbursement()
    RETURNS trigger AS
    $BODY$
    BEGIN
      NEW.reimbursement_type = NEW.reimbursement->>'type';
      NEW.reimbursement_amount = NEW.reimbursement->>'reimbursement_amount';

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_program_medication_insert
    BEFORE INSERT
    ON program_medications
    FOR EACH ROW
    EXECUTE PROCEDURE set_program_medication_reimbursement();
    """)

    execute("""
    CREATE TRIGGER on_program_medication_update
    BEFORE UPDATE
    ON program_medications
    FOR EACH ROW
    WHEN (OLD.reimbursement IS DISTINCT FROM NEW.reimbursement)
    EXECUTE PROCEDURE set_program_medication_reimbursement();
    """)

    execute("ALTER table program_medications ENABLE REPLICA TRIGGER on_program_medication_insert;")
    execute("ALTER table program_medications ENABLE REPLICA TRIGGER on_program_medication_update;")
  end
end
