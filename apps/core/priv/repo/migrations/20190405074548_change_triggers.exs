defmodule Core.Repo.Migrations.ChangeTriggers do
  @moduledoc false

  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("DROP TRIGGER IF EXISTS on_contract_update ON contracts;")

    execute("""
    CREATE TRIGGER on_contract_update
    AFTER UPDATE
    ON contracts
    FOR EACH ROW
    WHEN (OLD.contractor_payment_details IS DISTINCT FROM NEW.contractor_payment_details)
    EXECUTE PROCEDURE set_contracts_contractor_payment_details();
    """)

    execute("DROP TRIGGER IF EXISTS on_contract_request_update ON contract_requests;")

    execute("""
    CREATE TRIGGER on_contract_request_update
    AFTER UPDATE
    ON contract_requests
    FOR EACH ROW
    WHEN (OLD.contractor_payment_details IS DISTINCT FROM NEW.contractor_payment_details)
    EXECUTE PROCEDURE set_contract_requests_contractor_payment_details();
    """)

    execute("DROP TRIGGER IF EXISTS on_program_medication_update ON program_medications;")

    execute("""
    CREATE TRIGGER on_program_medication_update
    AFTER UPDATE
    ON program_medications
    FOR EACH ROW
    WHEN (OLD.reimbursement IS DISTINCT FROM NEW.reimbursement)
    EXECUTE PROCEDURE set_program_medication_reimbursement();
    """)

    execute("DROP TRIGGER IF EXISTS on_declaration_request_update ON declaration_requests;")

    execute("""
    CREATE TRIGGER on_declaration_request_update
    AFTER UPDATE
    ON declaration_requests
    FOR EACH ROW
    WHEN (OLD.authentication_method_current IS DISTINCT FROM NEW.authentication_method_current)
    EXECUTE PROCEDURE set_declaration_request_auth();
    """)

    execute("DROP TRIGGER IF EXISTS on_party_update_doctor_model ON parties;")

    execute("""
    CREATE TRIGGER on_party_update_doctor_model
    AFTER UPDATE
    ON parties
    FOR EACH ROW
    WHEN (OLD.educations IS DISTINCT FROM NEW.educations OR
          OLD.qualifications IS DISTINCT FROM NEW.qualifications OR
          OLD.specialities IS DISTINCT FROM NEW.specialities
          )
    EXECUTE PROCEDURE set_party_doctor_fields();
    """)

    execute("DROP TRIGGER IF EXISTS on_employee_update ON employees;")

    execute("""
    CREATE TRIGGER on_employee_update
    AFTER UPDATE
    ON employees
    FOR EACH ROW
    WHEN (OLD.speciality IS DISTINCT FROM NEW.speciality)
    EXECUTE PROCEDURE set_employee_speciality_officio();
    """)

    execute("DROP TRIGGER IF EXISTS on_legal_entity_update ON legal_entities;")

    execute("""
    CREATE TRIGGER on_legal_entity_update
    AFTER UPDATE
    ON legal_entities
    FOR EACH ROW
    WHEN (OLD.addresses IS DISTINCT FROM NEW.addresses OR OLD.phones IS DISTINCT FROM NEW.phones)
    EXECUTE PROCEDURE set_legal_entity_addresses_phones();
    """)
  end
end
