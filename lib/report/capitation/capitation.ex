defmodule Report.Capitation do
  @moduledoc false

  alias Report.Capitation.Cache
  alias Report.Capitation.CapitationReport
  alias Report.Capitation.CapitationReportDetail
  alias Report.Capitation.CapitationReportError
  alias Report.Capitation.CapitationProducer
  alias Report.Capitation.CapitationConsumer
  alias Report.Repo
  alias Report.Replica.LegalEntity
  import Ecto.Changeset
  import Ecto.Query

  def list(params) do
    Repo.paginate(CapitationReport, params)
  end

  def get_by_id(id) do
    CapitationReportDetail
    |> select([crd, l], %{legal_entity_id: crd.legal_entity_id, edrpu: l.edrpou})
    |> join(:inner, [crd], l in LegalEntity, l.id == crd.legal_entity_id and crd.id == ^id)
    |> Repo.one()
  end

  def run do
    billing_date = Map.put(Date.utc_today(), :day, 1)
    Cache.set_billing_date(billing_date)

    with {:ok, report} <-
           %CapitationReport{}
           |> changeset(%{billing_date: billing_date})
           |> Repo.insert() do
      Cache.set_report_id(report.id)
      [{supervisor_pid, _}] = Registry.lookup(:capitation_registry, "supervisor")
      children = Supervisor.which_children(supervisor_pid)
      {_, producer_pid, _, _} = Enum.find(children, fn {name, _, _, _} -> name == CapitationProducer end)
      {_, consumer_pid, _, _} = Enum.find(children, fn {name, _, _, _} -> name == CapitationConsumer end)

      GenStage.sync_subscribe(
        consumer_pid,
        to: producer_pid,
        max_demand: CapitationConsumer.config()[:max_demand]
      )
    end
  end

  def changeset(%CapitationReport{} = capitation_report, params) do
    fields = ~w(billing_date)a

    capitation_report
    |> cast(params, fields)
    |> validate_required(fields)
  end

  def changeset(%CapitationReportDetail{} = detail, params) do
    fields = ~w(capitation_report_id legal_entity_id contract_id mountain_group age_group declaration_count)a

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
