defmodule Core.Repo.Migrations.CreateMedicationRequestRequests do
  use Ecto.Migration

  def change do
    create table(:medication_request_requests, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:data, :map)
      add(:medication_qty, :integer)
      add(:ended_at, :string)
      add(:created_at, :string)
      add(:started_at, :string)
      add(:dispense_valid_to, :string)
      add(:dispense_valid_from, :string)
      add(:person_id, :uuid)
      add(:division_id, :uuid)
      add(:employee_id, :uuid)
      add(:medication_id, :uuid)
      add(:legal_entity_id, :uuid)
      add(:medical_program_id, :uuid)

      add(:request_number, :string)
      add(:status, :string)
      add(:medication_request_id, :uuid)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)


      timestamps(type: :utc_datetime_usec)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_medication_request_request_data()
    RETURNS trigger AS
    $BODY$
    BEGIN
      NEW.medication_qty = NEW.data->>'medication_qty';
      NEW.ended_at = NEW.data->>'ended_at';
      NEW.created_at = NEW.data->>'created_at';
      NEW.started_at = NEW.data->>'started_at';
      NEW.dispense_valid_to = NEW.data->>'dispense_valid_to';
      NEW.dispense_valid_from = NEW.data->>'dispense_valid_from';
      NEW.person_id = NEW.data->>'person_id';
      NEW.division_id = NEW.data->>'division_id';
      NEW.employee_id = NEW.data->>'employee_id';
      NEW.medication_id = NEW.data->>'medication_id';
      NEW.legal_entity_id = NEW.data->>'legal_entity_id';
      NEW.medical_program_id = NEW.data->>'medical_program_id';

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_medication_request_request_insert
    BEFORE INSERT
    ON medication_request_requests
    FOR EACH ROW
    EXECUTE PROCEDURE set_medication_request_request_data();
    """)

    execute("""
    CREATE TRIGGER on_medication_request_request_update
    BEFORE UPDATE
    ON medication_request_requests
    FOR EACH ROW
    WHEN (OLD.data IS DISTINCT FROM NEW.data)
    EXECUTE PROCEDURE set_medication_request_request_data();
    """)

    execute("ALTER table medication_request_requests ENABLE REPLICA TRIGGER on_medication_request_request_insert;")
    execute("ALTER table medication_request_requests ENABLE REPLICA TRIGGER on_medication_request_request_update;")
  end
end
