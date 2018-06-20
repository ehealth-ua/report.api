defmodule Report.Repo.Migrations.CreateCapitationReportErrors do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:capitation_report_errors, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:capitation_report_id, :uuid, null: false)
      add(:declaration_id, :uuid, null: false)
      add(:action, :string, null: false)
      add(:message, :text, null: false)
      timestamps(updated_at: false)
    end
  end
end
