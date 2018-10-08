defmodule Core.Application do
  @moduledoc """
  This is an entry point of report application.
  """
  use Application
  alias Confex.Resolver

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    cache_servers =
      if Application.get_env(:core, :environment) == :test do
        []
      else
        [
          worker(Core.Stats.Cache.MainStats, []),
          worker(Core.Stats.Cache.RegionStats, []),
          worker(Core.Stats.Cache.HistogramStats, [])
        ]
      end

    # Define workers and child supervisors to be supervised
    children =
      [
        worker(Core.Stats.Cache, []),
        supervisor(Core.Repo, [])
      ] ++ cache_servers

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Loads configuration in `:init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def init(_key, config), do: {:ok, Resolver.resolve!(config)}
end
