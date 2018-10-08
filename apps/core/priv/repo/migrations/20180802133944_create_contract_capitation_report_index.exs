defmodule Core.Repo.Migrations.CreateContractsCapitationReportIndex do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently if not exists contracts_capitation_index
      on contracts(id, status, is_suspended, start_date, end_date)
      where status = 'VERIFIED' AND is_suspended = FALSE;
    """)
  end
end
