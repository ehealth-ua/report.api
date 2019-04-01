defmodule Core.Repo.Migrations.CreateUkrMedRegistries do
  use Ecto.Migration

  def change do
    create table(:ukr_med_registries, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:edrpou, :string)
      add(:inserted_by, :uuid)
      add(:updated_by, :uuid)
      add(:type, :string)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
