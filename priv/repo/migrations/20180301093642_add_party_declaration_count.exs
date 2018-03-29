defmodule Report.Repo.Migrations.AddPartyDeclarationCount do
  @moduledoc false

  use Ecto.Migration

  def up do
    alter table(:parties) do
      add(:declaration_count, :integer)
    end

    execute("""
    CREATE OR REPLACE FUNCTION increment_declaration_count()
    RETURNS trigger AS
    $BODY$
    BEGIN
      UPDATE parties as p
      SET declaration_count = (
        CASE WHEN declaration_count IS NULL
        THEN 1
        ELSE declaration_count + 1 END
      )
      FROM employees as e
      WHERE e.id = NEW.employee_id AND p.id = e.party_id;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION decrement_declaration_count()
    RETURNS trigger AS
    $BODY$
    BEGIN
      UPDATE parties as p
      SET declaration_count = (
        CASE WHEN declaration_count IS NULL
        THEN NULL
        ELSE declaration_count - 1 END
      )
      FROM employees as e
      WHERE e.id = NEW.employee_id AND p.id = e.party_id;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_declaration_insert_party_counter
    BEFORE INSERT
    ON declarations
    FOR EACH ROW
    WHEN (NEW.status = 'active')
    EXECUTE PROCEDURE increment_declaration_count();
    """)

    execute("""
    CREATE TRIGGER on_declaration_update_party_counter
    BEFORE UPDATE
    ON declarations
    FOR EACH ROW
    WHEN (NEW.status = 'terminated' OR NEW.status = 'closed')
    EXECUTE PROCEDURE decrement_declaration_count();
    """)

    execute("ALTER table declarations ENABLE REPLICA TRIGGER on_declaration_insert_party_counter;")
    execute("ALTER table declarations ENABLE REPLICA TRIGGER on_declaration_update_party_counter;")
  end

  def down do
    execute("DROP TRIGGER IF EXISTS on_declaration_insert_party_counter ON declarations;")
    execute("DROP TRIGGER IF EXISTS on_declaration_update_party_counter ON declarations;")

    alter table(:parties) do
      remove(:declaration_count)
    end
  end
end
