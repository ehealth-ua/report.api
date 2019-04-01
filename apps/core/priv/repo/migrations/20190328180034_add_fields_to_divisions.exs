defmodule Core.Repo.Migrations.AddFieldsToDivisions do
  use Ecto.Migration

  def change do
    alter table(:divisions) do
      add(:dls_id, :string)
      add(:dls_verified, :boolean)
    end
  end
end
