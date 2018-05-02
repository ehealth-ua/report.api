defmodule Report.Repo.Migrations.AddDivisionAddessesIndex do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    create(index(:divisions, [:addresses], using: "GIN", concurrently: true))
  end
end
