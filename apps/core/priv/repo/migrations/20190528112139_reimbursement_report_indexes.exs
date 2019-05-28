defmodule Core.Repo.Migrations.ReimbursementReportIndexes do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    create(index(:medication_requests, [:created_at], concurrently: true))
    create(index(:medication_dispenses, [:medication_request_id], concurrently: true))
    create(index(:medication_dispenses, [:dispensed_at], concurrently: true))
  end
end
