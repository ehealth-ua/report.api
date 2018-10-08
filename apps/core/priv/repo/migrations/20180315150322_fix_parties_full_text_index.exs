defmodule Core.Repo.Migrations.FixPartiesFullTextIndex do
  @moduledoc false

  use Ecto.Migration

  def change do
    execute("DROP INDEX full_name_idx")

    execute("""
    CREATE INDEX full_name_idx ON parties
    USING GIN (to_tsvector('english', first_name || ' ' || last_name || ' ' || second_name));
    """)
  end
end
