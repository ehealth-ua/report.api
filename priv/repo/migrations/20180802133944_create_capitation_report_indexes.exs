defmodule Report.Repo.Migrations.CreateCapitationReportIndexes do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index contracts_capitation_index on contracts(id, status, is_suspended, start_date, end_date)
      where status = 'VERIFIED' AND is_suspended = FALSE;
    """)

    execute("""
    create index contract_employees_contract_id_index on contract_employees(contract_id);
    """)

    execute("""
    create index declarations_employee_id on declarations(employee_id);
    """)

    execute("""
    create index declarations_status_hstr_inserted_at_declaration_id_index on declarations_status_hstr(inserted_at);
    """)
  end
end
