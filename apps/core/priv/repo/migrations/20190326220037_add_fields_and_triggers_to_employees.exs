defmodule Core.Repo.Migrations.AddFieldsAndTriggersToEmployees do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add(:additional_info, :jsonb)

      add(:speciality_officio, :text)
      add(:speciality_officio_valid_to_date, :date)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_employee_speciality_officio()
    RETURNS trigger AS
    $BODY$
    BEGIN
      IF NEW.speciality->>'speciality' IS NOT NULL THEN
        NEW.speciality_officio = NEW.speciality->>'speciality';
        NEW.speciality_officio_valid_to_date = NEW.speciality->'valid_to_date';
      ELSE
        NEW.speciality_officio = null;
        NEW.speciality_officio_valid_to_date = null;
      END IF;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_employee_insert
    BEFORE INSERT
    ON employees
    FOR EACH ROW
    EXECUTE PROCEDURE set_employee_speciality_officio();
    """)

    execute("""
    CREATE TRIGGER on_employee_update
    BEFORE UPDATE
    ON employees
    FOR EACH ROW
    WHEN (OLD.speciality IS DISTINCT FROM NEW.speciality)
    EXECUTE PROCEDURE set_employee_speciality_officio();
    """)

    execute("ALTER table employees ENABLE REPLICA TRIGGER on_employee_insert;")
    execute("ALTER table employees ENABLE REPLICA TRIGGER on_employee_update;")
  end
end
