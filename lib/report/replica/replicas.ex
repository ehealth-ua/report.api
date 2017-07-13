defmodule Report.Replica.Replicas do
  @moduledoc """
  Context module for working with Replica Schemas
  """
  import Ecto.Query
  alias Report.Replica.Declaration
  alias Report.Repo

  def list_declarations do
    Repo.all(declaration_query())
  end

  def stream_declarations_beetween(from, to) do
    declaration_query()
    |> where_beetween(from, to)
    |> preload_declaration_assoc()
    |> Repo.stream(timeout: :infinity)
  end

  def get_oldest_declaration_date do
    declaration_query()
    |> select([:inserted_at])
    |> last
    |> Repo.one
    |> get_inserted_at
  end
  defp get_inserted_at(nil), do: DateTime.utc_now()
  defp get_inserted_at(declaration) when is_map(declaration), do: Map.get(declaration, :inserted_at)

  defp declaration_query do
    from(d in Declaration,
         where: d.status == "active",
         where: d.is_active,
         order_by: [desc: :inserted_at])
  end

  defp where_beetween(query, from, to) do
    query
    |> where([d], d.inserted_at >= ^from)
    |> where([d], d.inserted_at <= ^to)
  end

  defp preload_declaration_assoc(query) do
    query
    |> preload(:person)
    |> preload(:legal_entity)
  end
end
