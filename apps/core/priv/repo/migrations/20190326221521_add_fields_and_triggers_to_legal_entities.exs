defmodule Core.Repo.Migrations.AddFieldsAndTriggersToLegalEntities do
  use Ecto.Migration

  def change do
    alter table(:legal_entities) do
      add(:capitation_contract_id, :uuid)
      add(:archive, :jsonb)
      add(:website, :string)
      add(:beneficiary, :string)
      add(:receiver_funds_code, :string)
      add(:nhs_reviewed, :boolean)
      add(:nhs_comment, :text)
      add(:edr_verified, :boolean)

      add(:registration_country, :string)
      add(:registration_area, :string)
      add(:registration_region, :string)
      add(:registration_settlement, :string)
      add(:registration_settlement_type, :string)
      add(:registration_settlement_id, :string)
      add(:registration_street_type, :string)
      add(:registration_street, :string)
      add(:registration_building, :string)
      add(:registration_zip, :string)

      add(:residence_country, :string)
      add(:residence_area, :string)
      add(:residence_region, :string)
      add(:residence_settlement, :string)
      add(:residence_settlement_type, :string)
      add(:residence_settlement_id, :string)
      add(:residence_street_type, :string)
      add(:residence_street, :string)
      add(:residence_building, :string)
      add(:residence_zip, :string)

      add(:mobile_phone, :string)
      add(:land_line_phone, :string)
    end

    execute("""
    CREATE OR REPLACE FUNCTION set_legal_entity_addresses_phones()
    RETURNS trigger AS
    $BODY$
    DECLARE
      address jsonb;
      phone jsonb;
    BEGIN
      FOR address IN SELECT * FROM jsonb_array_elements(NEW.addresses) LOOP
        IF address->>'type' = 'REGISTRATION' THEN
          NEW.registration_country = address->>'country';
          NEW.registration_area = address->>'area';
          NEW.registration_region = address->>'region';
          NEW.registration_settlement = address->>'settlement';
          NEW.registration_settlement_type = address->>'settlement_type';
          NEW.registration_settlement_id = address->>'settlement_id';
          NEW.registration_street_type = address->>'street_type';
          NEW.registration_street = address->>'street';
          NEW.registration_building = CONCAT(address->>'building', ',', address->>'apartment');
          NEW.registration_zip = address->>'zip';
        END IF;

        IF address->>'type' = 'RESIDENCE' THEN
          NEW.residence_country = address->>'country';
          NEW.residence_area = address->>'area';
          NEW.residence_region = address->>'region';
          NEW.residence_settlement = address->>'settlement';
          NEW.residence_settlement_type = address->>'settlement_type';
          NEW.residence_settlement_id = address->>'settlement_id';
          NEW.residence_street_type = address->>'street_type';
          NEW.residence_street = address->>'street';
          NEW.residence_building = CONCAT(address->>'building', ',', address->>'apartment');
          NEW.residence_zip = address->>'zip';
        END IF;
      END LOOP;

      FOR phone IN SELECT * FROM jsonb_array_elements(NEW.phones) LOOP
        IF phone->>'type' = 'MOBILE' THEN
          NEW.mobile_phone = phone->>'number';
        END IF;

        IF phone->>'type' = 'LAND_LINE' THEN
          NEW.land_line_phone = phone->>'number';
        END IF;
      END LOOP;

      RETURN NEW;
    END;
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER on_legal_entity_insert
    BEFORE INSERT
    ON legal_entities
    FOR EACH ROW
    EXECUTE PROCEDURE set_legal_entity_addresses_phones();
    """)

    execute("""
    CREATE TRIGGER on_legal_entity_update
    BEFORE UPDATE
    ON legal_entities
    FOR EACH ROW
    WHEN (OLD.addresses IS DISTINCT FROM NEW.addresses OR OLD.phones IS DISTINCT FROM NEW.phones)
    EXECUTE PROCEDURE set_legal_entity_addresses_phones();
    """)

    execute("ALTER table legal_entities ENABLE REPLICA TRIGGER on_legal_entity_insert;")
    execute("ALTER table legal_entities ENABLE REPLICA TRIGGER on_legal_entity_update;")
  end
end
