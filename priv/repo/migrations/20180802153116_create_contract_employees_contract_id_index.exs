defmodule Report.Repo.Migrations.CreateContractEmployeesContractIdIndex do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently if not exists contract_employees_contract_id_index on contract_employees(contract_id);
    """)
  end
end
