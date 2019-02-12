defmodule Report.Web.ReimbursementController do
  @moduledoc false

  use Report.Web, :controller

  alias Core.Stats.ReimbursementStats
  alias Core.Stats.ReimbursementStatsCSV
  alias Report.Web.ReimbursementView
  alias Scrivener.Page

  action_fallback(Report.Web.FallbackController)

  def index(%Plug.Conn{req_headers: headers} = conn, params) do
    with %Page{} = paging <- ReimbursementStats.get_stats(params, headers) do
      conn
      |> put_view(ReimbursementView)
      |> render("index.json", stats: paging.entries, paging: paging)
    end
  end

  def download(conn, params) do
    with {:ok, csv_content} <- ReimbursementStatsCSV.get_stats(params) do
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~S(attachment; filename="report.csv"))
      |> send_resp(200, csv_content)
    end
  end
end
