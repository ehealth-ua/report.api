defmodule Core.Repo.Migrations.CreateCapitationReportDetails do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:capitation_report_details, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:capitation_report_id, :uuid, null: false)
      add(:legal_entity_id, :uuid, null: false)
      add(:contract_id, :uuid, null: false)
      add(:mountain_group, :boolean, null: false)
      add(:age_group, :string, null: false)
      add(:declaration_count, :integer, null: false)
    end
  end
end
