defmodule Report.Repo.Migrations.CreateDeclarationsEmployeeId do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently if not exists declarations_employee_id_index on declarations(employee_id);
    """)
  end
end
