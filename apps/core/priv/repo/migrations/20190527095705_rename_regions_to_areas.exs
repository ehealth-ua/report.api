defmodule Core.Repo.Migrations.RenameRegionsToAreas do
  use Ecto.Migration

  def change do
    rename table("regions"), to: table("areas")

    rename table("districts"), :region_id, to: :area_id
    rename table("settlements"), :region_id, to: :area_id
  end
end
