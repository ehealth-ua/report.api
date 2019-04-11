defmodule Core.Repo.Migrations.DivisionsSplitPhones do
  use Ecto.Migration

  def change do
    alter table(:divisions) do
      add(:mobile_phone, :string)
      add(:land_line_phone, :string)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_division_phones()
    RETURNS trigger AS
    $BODY$
    DECLARE
      phone jsonb;
    BEGIN
      FOR phone IN SELECT * FROM jsonb_array_elements(NEW.phones) LOOP
        IF phone->>'type' = 'MOBILE' THEN
          NEW.mobile_phone = phone->>'number';
        END IF;

        IF phone->>'type' = 'LAND_LINE' THEN
          NEW.land_line_phone = phone->>'number';
        END IF;
      END LOOP;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_division_insert
    BEFORE INSERT
    ON divisions
    FOR EACH ROW
    EXECUTE PROCEDURE set_division_phones();
    """)

    execute("""
    CREATE TRIGGER on_division_update
    BEFORE UPDATE
    ON divisions
    FOR EACH ROW
    WHEN (OLD.phones IS DISTINCT FROM NEW.phones)
    EXECUTE PROCEDURE set_division_phones();
    """)

    execute("ALTER table divisions ENABLE REPLICA TRIGGER on_division_insert;")
    execute("ALTER table divisions ENABLE REPLICA TRIGGER on_division_update;")
  end
end
