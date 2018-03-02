defmodule Report.Repo.Migrations.AddSpecialityToEmployee do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add(:speciality, :map)
    end
  end
end
