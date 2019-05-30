defmodule Core.Repo.Migrations.RenameDistrictsToRegions do
  use Ecto.Migration

  def change do
    rename table("districts"), to: table("regions")

    rename table("settlements"), :district_id, to: :region_id
  end
end
