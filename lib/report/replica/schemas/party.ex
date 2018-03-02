defmodule Report.Replica.Party do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "parties" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:second_name, :string)
    field(:educations, {:array, :map})
    field(:qualifications, {:array, :map})
    field(:specialities, {:array, :map})
    field(:science_degree, :map)
    field(:declaration_count, :integer)
    field(:declaration_limit, :integer)

    has_many(:users, Report.Replica.PartyUser, foreign_key: :party_id)

    timestamps()
  end
end
