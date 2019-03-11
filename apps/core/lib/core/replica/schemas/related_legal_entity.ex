defmodule Core.Replica.RelatedLegalEntity do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "related_legal_entities" do
    field(:reason, :string)
    field(:is_active, :boolean, default: false)
    field(:inserted_by, Ecto.UUID)

    field(:merged_from_id, Ecto.UUID)
    field(:merged_to_id, Ecto.UUID)

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
