defmodule Core.Repo.Migrations.CreateRegisterEntries do
  use Ecto.Migration

  def change do
    create table(:register_entries, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:status, :string)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)
      add(:person_id, :uuid)
      add(:document_type, :string)
      add(:document_number, :string)
      add(:register_id, :uuid)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
