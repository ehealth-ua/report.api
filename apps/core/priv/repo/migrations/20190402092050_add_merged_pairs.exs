defmodule Core.Repo.Migrations.AddMergedPairs do
  use Ecto.Migration

  def change do
    create table(:merged_pairs, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:master_person_id, :uuid)
      add(:merge_person_id, :uuid)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
