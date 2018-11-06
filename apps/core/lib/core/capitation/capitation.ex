defmodule Core.Capitation do
  @moduledoc false

  alias Core.CapitationReport
  alias Core.CapitationReportDetail
  alias Core.CapitationReportError
  alias Core.Replica.Contract
  alias Core.Replica.LegalEntity
  alias Core.Replica.RelatedLegalEntity
  alias Core.Repo
  import Ecto.Changeset
  import Ecto.Query
  require Logger

  defp edrpou_condition(query, %{"edrpou" => edrpou}) do
    where(query, [d, ci, l, r], l.edrpou == ^edrpou)
  end

  defp edrpou_condition(query, _), do: query

  defp report_id_condition(query, %{"report_id" => report_id}) do
    where(query, [d, ci, l, r], r.id == ^report_id)
  end

  defp report_id_condition(query, _), do: query

  defp legal_entity_condition(query, %{"legal_entity_id" => legal_entity_id}) do
    related =
      RelatedLegalEntity
      |> select([r], r.merged_from_id)
      |> where([r], r.merged_to_id == ^legal_entity_id)
      |> Repo.all()

    where(
      query,
      [d, ci],
      d.legal_entity_id in ^[legal_entity_id | related]
    )
  end

  defp legal_entity_condition(query, _), do: query

  def details(params) do
    count_age_group_subquery =
      subquery(
        CapitationReportDetail
        |> select([crd, contr], %{
          capitation_report_id: crd.capitation_report_id,
          legal_entity_id: crd.legal_entity_id,
          contract_id: crd.contract_id,
          contract_number: contr.contract_number,
          mountain_group: crd.mountain_group,
          age_group: crd.age_group,
          cnt: sum(crd.declaration_count)
        })
        |> join(:left, [crd], contr in Contract, contr.id == crd.contract_id)
        |> group_by([crd, contr], [
          crd.capitation_report_id,
          crd.legal_entity_id,
          crd.contract_id,
          contr.contract_number,
          crd.mountain_group,
          crd.age_group
        ])
      )

    arrgerated_count_age_group_subquery =
      subquery(
        count_age_group_subquery
        |> select([crd0], %{
          capitation_report_id: crd0.capitation_report_id,
          legal_entity_id: crd0.legal_entity_id,
          contract_id: crd0.contract_id,
          contract_number: crd0.contract_number,
          mountain_group: crd0.mountain_group,
          attributes: fragment(" json_agg(json_build_object(age_group, ?))", crd0.cnt)
        })
        |> group_by([crd0], [
          crd0.capitation_report_id,
          crd0.legal_entity_id,
          crd0.contract_id,
          crd0.contract_number,
          crd0.mountain_group
        ])
      )

    capitation_contracts_details_query =
      arrgerated_count_age_group_subquery
      |> select([crd1], %{
        capitation_report_id: crd1.capitation_report_id,
        legal_entity_id: crd1.legal_entity_id,
        contract_id: crd1.contract_id,
        contract_number: crd1.contract_number,
        details:
          fragment(
            "json_agg(json_build_object('mountain_group', ?, 'attributes', ?))",
            crd1.mountain_group,
            crd1.attributes
          )
      })
      |> group_by([crd1], [
        crd1.capitation_report_id,
        crd1.legal_entity_id,
        crd1.contract_id,
        crd1.contract_number
      ])

    total_count_age_groups_subquery =
      subquery(
        CapitationReportDetail
        |> distinct(true)
        |> select([c], %{
          capitation_report_id: c.capitation_report_id,
          legal_entity_id: c.legal_entity_id,
          contract_id: c.contract_id,
          age_group: c.age_group,
          tcnt: sum(c.declaration_count)
        })
        |> group_by([c], [c.capitation_report_id, c.legal_entity_id, c.contract_id, c.age_group])
      )

    aggregated_total_count_age_groups_subquery =
      subquery(
        total_count_age_groups_subquery
        |> select([c], %{
          capitation_report_id: c.capitation_report_id,
          legal_entity_id: c.legal_entity_id,
          contract_id: c.contract_id,
          total: fragment("json_agg(json_build_object(age_group, ?))", c.tcnt)
        })
        |> group_by([c], [c.capitation_report_id, c.legal_entity_id, c.contract_id])
      )

    total_details_query =
      aggregated_total_count_age_groups_subquery
      |> select([t, c], %{
        capitation_report_id: c.capitation_report_id,
        legal_entity_id: c.legal_entity_id,
        contract_id: c.contract_id,
        contract_number: c.contract_number,
        details: c.details,
        total: t.total
      })
      |> join(
        :inner,
        [t],
        c in subquery(capitation_contracts_details_query),
        c.contract_id == t.contract_id and c.legal_entity_id == t.legal_entity_id and
          c.capitation_report_id == t.capitation_report_id
      )

    main_report_detail_query =
      subquery(
        CapitationReportDetail
        |> distinct(true)
        |> select([d], %{
          report_id: d.capitation_report_id,
          contract_id: d.contract_id,
          legal_entity_id: d.legal_entity_id
        })
      )

    main_report_detail_query
    |> select([d, ci, l, r], %{
      billing_date: r.billing_date,
      report_id: d.report_id,
      legal_entity_id: d.legal_entity_id,
      edrpou: l.edrpou,
      legal_entity_name: l.name,
      capitation_contracts:
        fragment(
          "json_agg(json_build_object('contract_id', ?, 'contract_number', ?, 'details', ?, 'total', ?))",
          d.contract_id,
          ci.contract_number,
          ci.details,
          ci.total
        )
    })
    |> join(
      :left,
      [d],
      ci in subquery(total_details_query),
      ci.contract_id == d.contract_id and ci.legal_entity_id == d.legal_entity_id and
        ci.capitation_report_id == d.report_id
    )
    |> join(:left, [d, ci], l in LegalEntity, l.id == d.legal_entity_id)
    |> join(:inner, [d, ci, l], r in CapitationReport, r.id == d.report_id)
    |> group_by([d, ci, l, r], [
      r.billing_date,
      d.report_id,
      d.legal_entity_id,
      l.edrpou,
      l.name
    ])
    |> report_id_condition(params)
    |> edrpou_condition(params)
    |> legal_entity_condition(params)
    |> Repo.paginate(params)
  end

  def list(params) do
    page_size = Map.get(params, "page_size", "50")

    page_size =
      case Integer.parse(page_size) do
        {value, ""} when value > 100 -> 100
        {value, ""} -> value
        _ -> 50
      end

    CapitationReport
    |> order_by(desc: :billing_date)
    |> Repo.paginate(Map.put(params, "page_size", page_size))
  end

  def changeset(%CapitationReport{} = capitation_report, params) do
    fields = ~w(billing_date)a

    capitation_report
    |> cast(params, fields)
    |> validate_required(fields)
  end

  def changeset(%CapitationReportDetail{} = detail, params) do
    fields =
      ~w(capitation_report_id legal_entity_id contract_id mountain_group age_group declaration_count)a

    detail
    |> cast(params, fields)
    |> validate_required(fields)
  end

  def changeset(%CapitationReportError{} = error, params) do
    fields = ~w(capitation_report_id declaration_id action message)a

    error
    |> cast(params, fields)
    |> validate_required(fields)
  end
end
