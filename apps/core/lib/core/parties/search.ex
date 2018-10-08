defmodule Core.Parties.Search do
  @moduledoc false

  use Ecto.Schema
  alias Ecto.UUID

  schema "parties_search" do
    field(:ids, {:array, UUID})
  end
end
