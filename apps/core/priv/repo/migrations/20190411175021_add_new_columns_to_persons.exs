defmodule Core.Repo.Migrations.AddNewColumnsToPersons do
  use Ecto.Migration

  def change do
    alter table(:persons) do
      add(:gender, :string)
      add(:is_active, :boolean)
      add(:status, :string)
    end
  end
end
