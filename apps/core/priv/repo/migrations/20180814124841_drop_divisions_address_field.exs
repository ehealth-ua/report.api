defmodule Core.Repo.Migrations.DropDivisionsAddressField do
  use Ecto.Migration

  def change do
    alter table(:divisions) do
      remove(:addresses)
    end
  end
end
