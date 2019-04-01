defmodule Core.Repo.Migrations.CreateDictionaries do
  use Ecto.Migration

  def change do
    create table(:dictionaries, primary_key: false) do
      add(:id, :uuid)
      add(:name, :string, primary_key: true)
      add(:values, :map)
      add(:labels, :map)
      add(:is_active, :boolean, default: false)
    end
  end
end
