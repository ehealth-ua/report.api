defmodule Core.Repo.Migrations.CreateRegisters do
  use Ecto.Migration

  def change do
    create table(:registers, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:file_name, :string)
      add(:type, :string)
      add(:status, :string)
      add(:qty, :map)
      add(:errors, :map)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)
      add(:entity_type, :string)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
