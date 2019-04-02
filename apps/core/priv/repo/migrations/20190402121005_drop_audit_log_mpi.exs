defmodule Core.Repo.Migrations.DropAuditLogMpi do
  use Ecto.Migration

  def change do
    drop(table(:audit_log_mpi))
  end
end
