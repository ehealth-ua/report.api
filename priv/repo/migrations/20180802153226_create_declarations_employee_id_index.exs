defmodule Report.Repo.Migrations.CreateDeclarationsEmployeeId do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently declarations_employee_id on declarations(employee_id);
    """)
  end
end
