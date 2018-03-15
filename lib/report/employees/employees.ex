defmodule Report.Employees do
  @moduledoc false

  alias Report.Employees.Search
  alias Report.Replica.Employee
  alias Report.Repo
  import Ecto.Changeset
  import Ecto.Query

  @type_residence "RESIDENCE"

  def list(params) do
    with %Ecto.Changeset{valid?: true, changes: changes} <- changeset(params) do
      Employee
      |> add_full_name_search(changes)
      |> add_speciality_search(changes)
      |> where([e], e.employee_type == "DOCTOR")
      |> where([e], e.is_active)
      |> where([e], e.status == "APPROVED")
      |> where([e], not is_nil(e.division_id))
      |> join(:left, [e], p in assoc(e, :party))
      |> add_is_available_search(changes)
      |> preload([e, p], party: p)
      |> join(:left, [e, p], d in assoc(e, :division))
      |> preload([e, p, d], division: d)
      |> add_division_search(changes)
      |> add_division_name(changes)
      |> Repo.paginate(params)
    end
  end

  defp changeset(params) do
    cast(%Search{}, params, Search.__schema__(:fields))
  end

  defp add_is_available_search(query, changes) do
    case Map.get(changes, :is_available) do
      false ->
        query

      _ ->
        where(query, [e, p], p.declaration_count < p.declaration_limit)
    end
  end

  defp add_full_name_search(query, changes) do
    ts_query =
      changes
      |> Map.get(:full_name, "")
      |> String.split()
      |> Enum.join(" & ")

    if ts_query == "" do
      query
    else
      where(
        query,
        [e, p],
        fragment(
          "to_tsvector('russian', ? || ' ' || ? || ' ' || ?) @@ to_tsquery(?)",
          p.first_name,
          p.last_name,
          p.second_name,
          ^ts_query
        )
      )
    end
  end

  defp add_speciality_search(query, changes) do
    changes
    |> Map.take(~w(speciality)a)
    |> Enum.reduce(query, fn {_, v}, q ->
      where(q, [e], fragment("?->>'speciality' = ?", e.speciality, ^v))
    end)
  end

  defp add_division_search(query, changes) do
    params = Map.take(changes, ~w(region area settlement)a)

    if params == %{} do
      query
    else
      params = Map.put(params, :type, @type_residence)
      where(query, [..., d], fragment("? @> ?", d.addresses, ^[params]))
    end
  end

  defp add_division_name(query, changes) do
    changes
    |> Map.take(~w(division_name)a)
    |> Enum.reduce(query, fn {_, v}, q ->
      where(q, [..., d], ilike(d.name, ^("%" <> v <> "%")))
    end)
  end
end
