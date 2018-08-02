defmodule Report.Repo.Migrations.CapitationReportIndexImprovement do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently declarations_status_hstr_inserted_at_declaration_id_index on declarations_status_hstr(inserted_at, declaration_id);
    """)
  end
end
