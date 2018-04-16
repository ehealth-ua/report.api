defmodule Report do
  @moduledoc """
  This is an entry point of report application.
  """
  use Application
  alias Report.Web.Endpoint
  alias Confex.Resolver

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    cache_servers =
      if Application.get_env(:report_api, :environment) == :test do
        []
      else
        [
          worker(Report.Stats.Cache.MainStats, []),
          worker(Report.Stats.Cache.RegionStats, []),
          worker(Report.Stats.Cache.HistogramStats, [])
        ]
      end

    # Define workers and child supervisors to be supervised
    children =
      [
        worker(Report.Stats.Cache, []),

        # Start the Ecto repository
        supervisor(Report.Repo, []),
        # Start the endpoint when the application starts
        supervisor(Report.Web.Endpoint, []),
        # Starts a worker by calling: Report.Worker.start_link(arg1, arg2, arg3)
        # worker(Report.Worker, [arg1, arg2, arg3]),
        worker(Report.Scheduler, [])
      ] ++ cache_servers

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Report.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  # Loads configuration in `:init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def init(_key, config), do: {:ok, Resolver.resolve!(config)}
end
