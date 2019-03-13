defmodule Core.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    :telemetry.attach("log-handler", [:core, :repo, :query], &Core.TelemetryHandler.handle_event/4, nil)

    children = [{Core.Repo, []}]

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
