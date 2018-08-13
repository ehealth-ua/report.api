defmodule Report.Repo.Migrations.CapitationReportIndexImprovement do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently if not exists declarations_status_hstr_capitation_index
      on declarations_status_hstr (declaration_id, inserted_at, status)
    """)
  end
end
