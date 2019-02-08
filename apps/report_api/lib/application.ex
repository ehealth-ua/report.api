defmodule Report.Application do
  @moduledoc """
  This is an entry point of report application.
  """
  use Application
  alias Confex.Resolver
  alias Report.Web.Endpoint

  def start(_type, _args) do
    children = [{Endpoint, []}]

    children =
      if Application.get_env(:core, :environment) == :prod do
        children ++
          [
            {Cluster.Supervisor,
             [Application.get_env(:core, :topologies), [name: Report.ClusterSupervisor]]}
          ]
      else
        children
      end

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
