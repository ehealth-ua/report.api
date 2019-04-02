defmodule Core.Repo.Migrations.AddMergeCandidates do
  use Ecto.Migration

  def change do
    create table(:merge_candidates, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:person_id, references(:persons, type: :uuid))
      add(:master_person_id, references(:persons, type: :uuid))
      add(:status, :string)
      add(:config, :map)
      add(:details, :map)
      add(:score, :float)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
