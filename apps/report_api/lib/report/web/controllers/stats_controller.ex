defmodule Report.Web.StatsController do
  @moduledoc false

  use Report.Web, :controller

  alias Core.Stats.DivisionStats
  alias Core.Stats.MainStats
  alias Scrivener.Page

  action_fallback(Report.Web.FallbackController)

  @rpc_worker Application.get_env(:core, :rpc_worker)

  def index(conn, _params) do
    with {:ok, main_stats} <- @rpc_worker.run("reports", ReportCache.Rpc, :get_main_stats, []) do
      render(conn, "index.json", stats: main_stats)
    end
  end

  def division(conn, %{"id" => id}) do
    with {:ok, main_stats} <- MainStats.get_division_stats(id) do
      render(conn, "index.json", main_stats)
    end
  end

  def regions(conn, _) do
    with {:ok, main_stats} <- @rpc_worker.run("reports", ReportCache.Rpc, :get_regions_stats, []) do
      render(conn, "regions.json", stats: main_stats)
    end
  end

  def histogram(conn, _params) do
    with {:ok, main_stats} <- @rpc_worker.run("reports", ReportCache.Rpc, :get_histogram_stats, []) do
      render(conn, "index.json", stats: main_stats)
    end
  end

  def divisions(conn, params) do
    with {:ok, %Page{} = paging} <- DivisionStats.get_map_stats(params) do
      render(conn, "divisions.json", divisions: paging.entries, paging: paging)
    end
  end
end
