defmodule Report.Web.CapitationController do
  @moduledoc false
  use Report.Web, :controller
  alias Report.Capitation
  alias Scrivener.Page

  action_fallback(Report.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Capitation.list(params) do
      render(conn, "index.json", reports: paging.entries, paging: paging)
    end
  end

  def show(conn, %{"id" => id}) do
    with %{} = capitation_report_detail <- Capitation.get_by_id(id) do
      render(conn, "show.json", data: capitation_report_detail)
    end
  end
end
