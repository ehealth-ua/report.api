defmodule Core.Employees do
  @moduledoc false

  alias Core.Employees.Search
  alias Core.Replica.Employee
  alias Core.Repo
  import Ecto.Changeset
  import Ecto.Query

  @type_residence "RESIDENCE"

  def list(params) do
    with %Ecto.Changeset{valid?: true, changes: changes} <- changeset(params),
         employee_ids <- get_employee_ids(changes) do
      get_employees(employee_ids, params)
    end
  end

  defp get_employee_ids(changes) do
    Employee
    |> add_id_search(changes)
    |> add_full_name_search(changes)
    |> add_speciality_search(changes)
    |> where([e], e.employee_type == "DOCTOR")
    |> where([e], e.is_active)
    |> where([e], e.status == "APPROVED")
    |> where([e], not is_nil(e.division_id))
    |> join(:left, [e], p in assoc(e, :party))
    # |> preload([e, p], party: p)
    |> join(:left, [e, p], d in assoc(e, :division))
    # |> preload([e, p, d], division: d)
    |> join(:inner, [..., d], da in assoc(d, :addresses))
    |> join(:left, [e, p, d, da], le in assoc(e, :legal_entity))
    # |> preload([e, p, d, da, le], legal_entity: le)
    |> add_division_id_search(changes)
    |> add_division_search(changes)
    |> add_division_name(changes)
    |> select([e], {e.id})
    |> Repo.all()
    |> Enum.map(fn {id} -> id end)
  end

  defp get_employees(ids, params) do
    page =
      Employee
      |> select([e], e)
      |> where([e], e.id in ^ids)
      |> Repo.paginate(params)

    %{
      page
      | entries:
          page.entries
          |> Repo.preload(:legal_entity)
          |> Repo.preload(:party)
          |> Repo.preload(division: [:legal_entity])
    }
  end

  defp add_id_search(query, %{id: id}) when not is_nil(id) do
    where(query, [e], e.id == ^id)
  end

  defp add_id_search(query, _), do: query

  def get_by_id(id) do
    with %Employee{} = employee <- Repo.get(Employee, id) do
      employee
      |> Repo.preload(:legal_entity)
      |> Repo.preload(:party)
      |> Repo.preload(division: [:legal_entity])
    end
  end

  defp changeset(params) do
    cast(%Search{}, params, Search.__schema__(:fields))
  end

  defp add_full_name_search(query, changes) do
    ts_query =
      changes
      |> Map.get(:full_name, "")
      |> String.split()
      |> Enum.map(fn word -> word <> ":*" end)
      |> Enum.join(" & ")
      |> String.downcase()

    if ts_query == "" do
      query
    else
      where(
        query,
        [e, p],
        fragment(
          "to_tsvector('english', ? || ' ' || ? || ' ' || ?) @@ to_tsquery(?)",
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

  defp add_division_id_search(query, changes) do
    changes
    |> Map.take(~w(division_id)a)
    |> Enum.reduce(query, fn {_, v}, q ->
      where(q, [e], e.division_id == ^v)
    end)
  end

  defp add_division_search(query, changes) do
    params = Map.take(changes, ~w(region area settlement)a)

    if params == %{} do
      query
    else
      params = Map.put(params, :type, @type_residence)

      Enum.reduce(params, query, fn {key, val}, acc ->
        query_divisions_by_param(acc, key, val)
      end)
    end
  end

  defp query_divisions_by_param(query, field, value) do
    where(query, [e, p, d, da, le], field(da, ^field) == ^value)
  end

  defp add_division_name(query, changes) do
    changes
    |> Map.take(~w(division_name)a)
    |> Enum.reduce(query, fn {_, v}, q ->
      where(q, [e, p, d, da, le], ilike(d.name, ^("%" <> v <> "%")))
    end)
  end
end
