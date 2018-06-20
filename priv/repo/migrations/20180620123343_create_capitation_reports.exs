defmodule Report.Repo.Migrations.CreateCapitationReports do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:captiation_reports, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:billing_date, :date, null: false)
      timestamps(updated_at: false)
    end
  end
end
