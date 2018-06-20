defmodule Report.Capitation.CapitationReportError do
  @moduledoc false

  use Ecto.Schema
  alias Ecto.UUID

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "capitation_report_errors" do
    field(:capitation_report_id, UUID)
    field(:declaration_id, UUID)
    field(:action, :string)
    field(:message, :string)
    timestamps(updated_at: false)
  end
end
