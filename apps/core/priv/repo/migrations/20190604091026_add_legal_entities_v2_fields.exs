defmodule Core.Repo.Migrations.AddLegalEntitiesV2Fields do
  use Ecto.Migration

  def change do
    alter table("legal_entities") do
      modify(:name, :string, null: true)
      modify(:short_name, :string, null: true)
      modify(:public_name, :string, null: true)
      modify(:owner_property_type, :string, null: true)
      modify(:legal_form, :string, null: true)
      modify(:kveds, :map, null: true)

      add(:status_reason, :text)
      add(:reason, :text)
      add(:nhs_unverified_at, :utc_datetime_usec)
      add(:edr_data_id, :uuid)
      add(:registration_address, :map, null: true)
      add(:residence_address, :map, null: true)
      add(:license_id, :uuid)
      add(:accreditation, :map, null: true)
    end
  end
end
