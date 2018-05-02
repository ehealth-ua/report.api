defmodule Report.Repo.Migrations.AddDeclarationIndex do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    create(index(:declarations, [:status, :division_id], concurrently: true))
  end
end
