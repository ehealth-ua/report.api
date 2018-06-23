defmodule Report.Capitation.CapitationReportDetail do
  @moduledoc false

  use Ecto.Schema
  alias Ecto.UUID

  @age_group_0_5 "0-5"
  @age_group_6_17 "6-17"
  @age_group_18_39 "18-39"
  @age_group_40_65 "40-65"
  @age_group_65 "65+"

  def age_group(:"0-5"), do: @age_group_0_5
  def age_group(:"6-17"), do: @age_group_6_17
  def age_group(:"18-39"), do: @age_group_18_39
  def age_group(:"40-65"), do: @age_group_40_65
  def age_group(:"65+"), do: @age_group_65

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "capitation_report_details" do
    field(:capitation_report_id, UUID)
    field(:legal_entity_id, UUID)
    field(:contract_id, UUID)
    field(:mountain_group, :boolean)
    field(:age_group, :string)
    field(:declaration_count, :integer)
  end
end
