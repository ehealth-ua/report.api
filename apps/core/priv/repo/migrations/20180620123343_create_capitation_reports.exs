defmodule Core.Repo.Migrations.CreateCapitationReports do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:capitation_reports, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:billing_date, :date, null: false)
      timestamps(updated_at: false)
    end
  end
end
