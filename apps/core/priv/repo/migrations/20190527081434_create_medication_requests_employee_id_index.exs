defmodule Core.Repo.Migrations.CreateMedicationRequestsEmployeeIdIndex do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("""
    create index concurrently if not exists medication_requests_employee_id_index on medication_requests(employee_id);
    """)
  end
end
