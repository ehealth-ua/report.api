defmodule Core.Repo.Migrations.ChangeAndAddFieldsToDeclarations do
  use Ecto.Migration

  def change do
    alter table(:declarations) do
      add(:declaration_number, :string)
      add(:overlimit, :boolean)
      modify(:reason_description, :text)
    end
  end
end
