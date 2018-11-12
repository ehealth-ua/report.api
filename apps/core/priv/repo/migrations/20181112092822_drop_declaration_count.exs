defmodule Core.Repo.Migrations.DropDeclarationCount do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("DROP TRIGGER IF EXISTS on_declaration_insert_party_counter ON declarations;")
    execute("DROP TRIGGER IF EXISTS on_declaration_update_party_counter ON declarations;")
    execute("DROP FUNCTION IF EXISTS increment_declaration_count();")
    execute("DROP FUNCTION IF EXISTS decrement_declaration_count();")

    alter table(:parties) do
      remove(:declaration_count)
    end
  end
end
