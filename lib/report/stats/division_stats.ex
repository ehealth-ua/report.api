defmodule Report.Stats.DivisionStats do
  @moduledoc false

  import Ecto.Query
  import Ecto.Changeset
  import Report.Replica.Replicas
  import Report.Stats.DivisionStatsValidator

  alias Report.Replica.Division
  alias Report.Replica.Employee
  alias Report.Repo
  alias Report.Stats.DivisionsRequest

  @type_residence "RESIDENCE"
  @type_owner Employee.type(:owner)
  @type_pharmacy_owner Employee.type(:pharmacy_owner)

  @fields_address ~w(
    area
    region
    settlement
  )a

  def get_map_stats(params) do
    with %Ecto.Changeset{valid?: true} = changeset <- divisions_changeset(%DivisionsRequest{}, params),
         divisions <- divisions_by_changeset(changeset, params) do
      {:ok, divisions}
    end
  end

  def divisions_by_changeset(changeset, params) do
    Division
    |> select([d], d)
    |> params_query(%{
      "id" => get_change(changeset, :id),
      "type" => get_change(changeset, :type),
      "status" => "ACTIVE",
      "is_active" => true
    })
    |> query_legal_entity_id(get_change(changeset, :legal_entity_id))
    |> query_name(get_change(changeset, :name))
    |> query_locations(changeset.changes)
    |> query_addresses(changeset.changes)
    |> join(:inner, [d], l in assoc(d, :legal_entity))
    |> query_legal_entity_name(get_change(changeset, :legal_entity_name))
    |> query_legal_entity_edrpou(get_change(changeset, :legal_entity_edrpou))
    |> join(
      :inner,
      [..., l],
      e in Employee,
      e.legal_entity_id == l.id and e.employee_type in [@type_owner, @type_pharmacy_owner] and e.is_active
    )
    |> join(:inner, [..., e], innm in assoc(e, :party))
    |> preload([..., l, e, p], legal_entity: {l, employees: {e, party: p}})
    |> Repo.paginate(params)
  end

  defp query_name(query, nil), do: query
  defp query_name(query, name), do: ilike_query(query, :name, name)

  defp query_legal_entity_id(query, nil), do: query
  defp query_legal_entity_id(query, id), do: where(query, [d], d.legal_entity_id == ^id)

  defp query_locations(query, %{
         north: tlat,
         east: tlong,
         south: blat,
         west: blong
       }) do
    where(query, fragment("location && ST_MakeEnvelope(?, ?, ?, ?, 4326)", ^tlong, ^tlat, ^blong, ^blat))
  end

  defp query_locations(query, _), do: query

  defp query_addresses(query, changes) do
    params = prepare_address_params(changes)

    if map_size(params) > 1 do
      where(query, [d], fragment("? @> ?", d.addresses, ^[params]))
    else
      query
    end
  end

  defp prepare_address_params(changes) do
    Enum.reduce(changes, %{"type" => @type_residence}, fn {key, val}, acc ->
      case key in @fields_address do
        true -> Map.put(acc, Atom.to_string(key), val)
        _ -> acc
      end
    end)
  end

  defp query_legal_entity_name(query, nil), do: query

  defp query_legal_entity_name(query, name) do
    where(query, [..., l], ilike(l.name, ^("%" <> name <> "%")))
  end

  defp query_legal_entity_edrpou(query, nil), do: query

  defp query_legal_entity_edrpou(query, edrpou) do
    where(query, [..., l], l.edrpou == ^edrpou)
  end
end
