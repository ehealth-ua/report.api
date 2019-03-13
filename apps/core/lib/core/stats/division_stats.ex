defmodule Core.Stats.DivisionStats do
  @moduledoc false

  import Ecto.Query
  import Ecto.Changeset
  import Core.Replica.Replicas
  import Core.Stats.DivisionStatsValidator

  alias Core.Replica.Division
  alias Core.Replica.Employee
  alias Core.Repo
  alias Core.Stats.DivisionsRequest

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
         division_ids <- division_ids_by_changeset(changeset),
         divisions <- divisions_by_ids(division_ids, params) do
      {:ok, divisions}
    end
  end

  def division_ids_by_changeset(changeset) do
    Division
    |> select([d], {d.id})
    |> params_query(%{
      "id" => get_change(changeset, :id),
      "type" => get_change(changeset, :type),
      "status" => "ACTIVE",
      "is_active" => true
    })
    |> join(:inner, [d], da in assoc(d, :addresses))
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
      on: e.legal_entity_id == l.id and e.employee_type in [@type_owner, @type_pharmacy_owner] and e.is_active
    )
    |> Repo.all()
    |> Enum.map(fn {id} -> id end)
  end

  def divisions_by_ids(ids, params) do
    Division
    |> select([d], d)
    |> where([d], d.id in ^ids)
    |> join(:inner, [d], l in assoc(d, :legal_entity))
    |> join(
      :inner,
      [..., l],
      e in Employee,
      on: e.legal_entity_id == l.id and e.employee_type in [@type_owner, @type_pharmacy_owner] and e.is_active
    )
    |> join(:inner, [..., e], innm in assoc(e, :party))
    |> preload([..., l, e, p], legal_entity: {l, employees: {e, party: p}})
    |> preload([:addresses])
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
      Enum.reduce(params, query, fn {key, val}, acc ->
        query_addresses_by_param(acc, key, val)
      end)
    else
      query
    end
  end

  defp query_addresses_by_param(query, field, value) do
    where(query, [..., da], field(da, ^field) == ^value)
  end

  defp prepare_address_params(changes) do
    Enum.reduce(changes, %{type: @type_residence}, fn {key, val}, acc ->
      case key in @fields_address do
        true -> Map.put(acc, key, val)
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
