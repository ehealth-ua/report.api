defmodule ReportCache.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias ReportCache.Stats.Cache
  alias ReportCache.Stats.HistogramStats
  alias ReportCache.Stats.MainStats
  alias ReportCache.Stats.RegionStats

  def start(_type, _args) do
    # List all child processes to be supervised
    cache_servers =
      if Application.get_env(:core, :environment) == :test do
        []
      else
        [
          {MainStats, []},
          {RegionStats, []},
          {HistogramStats, []}
        ]
      end

    # Define workers and child supervisors to be supervised
    children = [{Cache, []}] ++ cache_servers

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReportCache.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
