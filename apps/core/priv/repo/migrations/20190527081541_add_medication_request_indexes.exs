defmodule Core.Repo.Migrations.AddMedicationRequestIndexes do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    create(index(:medication_requests, [:status, :division_id], concurrently: true))
  end
end
