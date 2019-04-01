defmodule Core.Repo.Migrations.ChangeAndAddFieldsAndTriggersToParties do
  use Ecto.Migration

  def change do
    alter table(:parties) do
      add(:gender, :string)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)
      add(:no_tax_id, :boolean)

      add(:educations_qty, :integer, default: 0)
      add(:qualifications_qty, :integer, default: 0)
      add(:specialities_qty, :integer, default: 0)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_party_doctor_fields()
    RETURNS trigger AS
    $BODY$
    BEGIN
      IF NEW.educations IS NOT NULL THEN
        NEW.educations_qty = jsonb_array_length(NEW.educations);
      END IF;

      IF NEW.qualifications IS NOT NULL THEN
        NEW.qualifications_qty = jsonb_array_length(NEW.qualifications);
      END IF;

      IF NEW.specialities IS NOT NULL THEN
        NEW.specialities_qty = jsonb_array_length(NEW.specialities);
      END IF;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_party_insert_doctor_model
    BEFORE INSERT
    ON parties
    FOR EACH ROW
    EXECUTE PROCEDURE set_party_doctor_fields();
    """)

    execute("""
    CREATE TRIGGER on_party_update_doctor_model
    BEFORE UPDATE
    ON parties
    FOR EACH ROW
    WHEN (OLD.educations IS DISTINCT FROM NEW.educations OR
          OLD.qualifications IS DISTINCT FROM NEW.qualifications OR
          OLD.specialities IS DISTINCT FROM NEW.specialities
          )
    EXECUTE PROCEDURE set_party_doctor_fields();
    """)

    execute("ALTER table parties ENABLE REPLICA TRIGGER on_party_insert_doctor_model;")
    execute("ALTER table parties ENABLE REPLICA TRIGGER on_party_update_doctor_model;")
  end
end
