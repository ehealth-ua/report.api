defmodule Core.Repo.Migrations.AddProgramsTypeField do
  use Ecto.Migration

  def change do
    alter table(:medical_programs) do
      add(:type, :text)
    end
  end
end
