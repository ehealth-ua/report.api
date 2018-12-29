defmodule Core.Repo.Migrations.AddUpdatedReimbursmentModelFields do
  use Ecto.Migration

  def change do
    alter table(:medication_requests) do
      add(:intent, :string, null: false)
      add(:category, :string, null: false)
      add(:context, :map)
      add(:dosage_instruction, {:array, :map})
    end
  end
end
