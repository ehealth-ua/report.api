defmodule Report.Web.CapitationController do
  @moduledoc false
  use Report.Web, :controller
  alias Core.Capitation
  alias Report.Validators.JsonSchema
  alias Report.Web.CapitationView
  alias Scrivener.Page

  action_fallback(Report.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Capitation.list(params) do
      conn
      |> put_view(CapitationView)
      |> render("index.json", reports: paging.entries, paging: paging)
    end
  end

  def details(conn, params) do
    with :ok <- JsonSchema.validate(:capitation_report_details, params),
         %Page{} = paging <- Capitation.details(params) do
      conn
      |> put_view(CapitationView)
      |> render("details.json", report_details: paging.entries, paging: paging)
    end
  end
end
