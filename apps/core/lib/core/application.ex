defmodule Core.Application do
  @moduledoc """
  This is an entry point of report application.
  """
  use Application
  alias Confex.Resolver

  def start(_type, _args) do
    children = [{Core.Repo, []}]

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  def init(_key, config), do: {:ok, Resolver.resolve!(config)}
end
