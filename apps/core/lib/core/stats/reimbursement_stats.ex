defmodule Core.Stats.ReimbursementStats do
  @moduledoc false

  alias Core.Connection
  alias Core.Redis
  alias Core.Replica.Employee
  alias Core.Replica.LegalEntity
  alias Core.Replica.MedicationDispense.Details
  alias Core.Replica.MedicationRequest
  alias Core.Repo
  import Core.Stats.ReimbursementStatsValidator, only: [validate: 3]
  import Ecto.Query

  def get_stats(params, headers) do
    legal_entity_id = Connection.get_legal_entity_id(headers)
    user_id = Connection.get_user_id(headers)

    with {%Ecto.Changeset{valid?: true, changes: changes}, legal_entity} <- validate(params, legal_entity_id, user_id),
         %{dispense: %{changes: dispense_changes}} <- changes.period.changes,
         %{request: %{changes: request_changes}} <- changes.period.changes,
         cache_key <- get_cache_key(dispense_changes, request_changes, legal_entity_id),
         query <- get_data_query(dispense_changes, request_changes, legal_entity) do
      total_entries =
        case Redis.get(cache_key) do
          {:ok, count} ->
            count

          _ ->
            count = query |> get_count_query() |> Repo.one()
            Redis.setex(cache_key, Confex.fetch_env!(:core, :cache)[:list_reimbursement_report_ttl], count)
            count
        end

      options =
        params
        |> Map.take(~w(page page_size))
        |> Map.put("options", total_entries: total_entries)
        |> Repo.paginator_options()

      EctoPaginator.paginate(get_data(query, options), total_entries, options)
    else
      {%Ecto.Changeset{valid?: false} = changeset, _} -> changeset
      error -> error
    end
  end

  defp get_data(query, %{page_number: page_number, page_size: page_size}) do
    entries =
      query
      |> limit(^page_size)
      |> offset(^(page_size * (page_number - 1)))
      |> select([mr, md, e, p_req, le, d_req, mp_req, m, p, d_dis, le_dis, mp_dis], %{
        medication_request: mr,
        division: d_req,
        employee: %{e | legal_entity: le, party: p_req},
        medical_program: mp_req,
        medication: m,
        medication_dispense: %{
          medication_dispense: md,
          party: p,
          division: d_dis,
          legal_entity: le_dis,
          medical_program: mp_dis
        }
      })
      |> Repo.all()

    medication_dispense_ids =
      entries
      |> Enum.map(fn item ->
        dispense =
          item
          |> Map.get(:medication_dispense, %{})
          |> Map.get(:medication_dispense, %{}) || %{}

        Map.get(dispense, :id)
      end)
      |> Enum.filter(&Kernel.!(is_nil(&1)))

    details =
      Details
      |> where([mdd], mdd.medication_dispense_id in ^medication_dispense_ids)
      |> join(:left, [mdd], m in assoc(mdd, :medication))
      |> preload([mdd, m], medication: m)
      |> Repo.all()
      |> Enum.group_by(&Map.get(&1, :medication_dispense_id))

    Enum.map(entries, fn item ->
      dispense =
        item
        |> Map.get(:medication_dispense, %{})
        |> Map.get(:medication_dispense)

      if is_nil(dispense) do
        item
      else
        put_in(item, [:medication_dispense, :details], Map.get(details, dispense.id))
      end
    end)
  end

  defp get_data_query(%{from: dispense_from, to: dispense_to}, %{from: request_from, to: request_to}, legal_entity) do
    MedicationRequest
    |> where(
      [mr],
      fragment("? BETWEEN ? AND ?", mr.created_at, ^request_from, ^request_to) and mr.intent == "order"
    )
    |> join_medication_dispense()
    |> where([mr, md], fragment("? BETWEEN ? AND ?", md.dispensed_at, ^dispense_from, ^dispense_to))
    |> do_get_data(legal_entity)
  end

  defp get_data_query(%{from: from, to: to}, _, legal_entity) do
    MedicationRequest
    |> join_medication_dispense()
    |> where([mr, md], fragment("? BETWEEN ? AND ?", md.dispensed_at, ^from, ^to))
    |> do_get_data(legal_entity)
  end

  defp get_data_query(_, %{from: from, to: to}, legal_entity) do
    MedicationRequest
    |> where(
      [mr],
      fragment("? BETWEEN ? AND ?", mr.created_at, ^from, ^to) and mr.intent == "order"
    )
    |> join_medication_dispense()
    |> do_get_data(legal_entity)
  end

  defp get_count_query(query) do
    query
    |> distinct([mr], mr.id)
    |> group_by([mr], [:id])
    |> subquery()
    |> select([a], count(a.id))
  end

  defp do_get_data(query, legal_entity) do
    query
    |> join(:left, [mr, md], e in Employee, on: e.id == mr.employee_id)
    |> join(:left, [mr, md, e], p_req in assoc(e, :party))
    |> join(:left, [mr, md, e, p_req], le in LegalEntity, on: le.id == e.legal_entity_id)
    |> join(:left, [mr], d_req in assoc(mr, :division))
    |> join(:left, [mr], mp_req in assoc(mr, :medical_program))
    |> join(:left, [mr], m in assoc(mr, :medication))
    |> join(:left, [mr, md], p_dis in assoc(md, :party))
    |> join(:left, [mr, md], d_dis in assoc(md, :division))
    |> join(:left, [mr, md], le_dis in assoc(md, :legal_entity))
    |> join(:left, [mr, md], mp_dis in assoc(md, :medical_program))
    |> filter_by_legal_entity(legal_entity)
  end

  defp filter_by_legal_entity(query, %LegalEntity{id: id, type: "MSP"}) do
    where(query, [mr, md, e, p_req, le], le.id == ^id and le.status == "ACTIVE")
  end

  defp filter_by_legal_entity(query, %LegalEntity{id: id, type: "PHARMACY"}) do
    where(
      query,
      [mr, md, e, p_req, le, d_req, mp_req, m, p, d_dis, le_dis],
      le_dis.id == ^id and le_dis.status == "ACTIVE"
    )
  end

  defp join_medication_dispense(query) do
    join(query, :left, [mr], md in assoc(mr, :medication_dispense), on: mr.id == md.medication_request_id)
  end

  def get_cache_key(dispense_changes, request_changes, legal_entity_id) do
    key =
      Enum.reduce(dispense_changes, "count_reimbursement_report", fn
        {k, v}, acc when is_list(v) -> "#{acc}_#{k}_#{Enum.sort(v)}"
        {k, v}, acc -> "#{acc}_#{k}_#{v}"
      end)

    key =
      Enum.reduce(request_changes, key, fn
        {k, v}, acc when is_list(v) -> "#{acc}_#{k}_#{Enum.sort(v)}"
        {k, v}, acc -> "#{acc}_#{k}_#{v}"
      end)

    key = "#{key}_#{legal_entity_id}"

    :md5 |> :crypto.hash(key) |> Base.encode64()
  end
end
