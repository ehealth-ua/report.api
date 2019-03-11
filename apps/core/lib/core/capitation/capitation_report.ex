defmodule Core.CapitationReport do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "capitation_reports" do
    field(:billing_date, :date)
    timestamps(type: :utc_datetime, updated_at: false)
  end
end
