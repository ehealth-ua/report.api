defmodule Core.Parties do
  @moduledoc false

  alias Core.Parties.Search
  alias Core.Replica.Party
  alias Core.Repo
  import Ecto.Changeset
  import Ecto.Query

  def list(ids) do
    with %Ecto.Changeset{valid?: true, changes: changes} <- changeset(ids) do
      {:ok,
       Party
       |> select([p], [:id, :declaration_count])
       |> where([p], p.id in ^Map.get(changes, :ids))
       |> Repo.all()}
    end
  end

  def changeset(attrs) do
    %Search{}
    |> cast(attrs, ~w(ids)a)
    |> validate_required(~w(ids)a)
  end
end
