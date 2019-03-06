defmodule Core.Repo.Migrations.AddReasonFieldsToDeclarations do
  use Ecto.Migration

  def change do
    alter table(:declarations) do
      add(:reason, :string)
      add(:reason_description, :string)
    end
  end
end
