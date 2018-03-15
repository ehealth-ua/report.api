defmodule Report.Repo.Migrations.AddPartiesFullTextIndex do
  @moduledoc false

  use Ecto.Migration

  def change do
    execute("""
    CREATE INDEX full_name_idx ON parties
    USING GIN (to_tsvector('russian', first_name || ' ' || last_name || ' ' || second_name));
    """)
  end
end
