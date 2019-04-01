defmodule Core.Repo.Migrations.ChangeAndAddFieldsAndTriggersToContracts do
  use Ecto.Migration

  def change do
    alter table(:contracts) do
      modify(:status_reason, :text)
      add(:medical_program_id, :uuid)
      add(:reason, :text)
      modify(:contractor_payment_details, :map, null: true)
      add(:contractor_payment_details_mfo, :string)
      add(:contractor_payment_details_bank_name, :string)
      add(:contractor_payment_details_payer_account, :string)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_contracts_contractor_payment_details()
    RETURNS trigger AS
    $BODY$
    BEGIN
      NEW.contractor_payment_details_mfo = NEW.contractor_payment_details->>'MFO';
      NEW.contractor_payment_details_bank_name = NEW.contractor_payment_details->>'bank_name';
      NEW.contractor_payment_details_payer_account = NEW.contractor_payment_details->>'payer_account';
      NEW.contractor_payment_details = null;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_contract_insert
    BEFORE INSERT
    ON contracts
    FOR EACH ROW
    EXECUTE PROCEDURE set_contracts_contractor_payment_details();
    """)

    execute("""
    CREATE TRIGGER on_contract_update
    BEFORE UPDATE
    ON contracts
    FOR EACH ROW
    WHEN (OLD.contractor_payment_details IS DISTINCT FROM NEW.contractor_payment_details)
    EXECUTE PROCEDURE set_contracts_contractor_payment_details();
    """)

    execute("ALTER table contracts ENABLE REPLICA TRIGGER on_contract_insert;")
    execute("ALTER table contracts ENABLE REPLICA TRIGGER on_contract_update;")
  end
end
