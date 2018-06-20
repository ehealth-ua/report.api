defmodule Report.Capitation.CapitationReportDetail do
  @moduledoc false

  use Ecto.Schema
  alias Ecto.UUID

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
