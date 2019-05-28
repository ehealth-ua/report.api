defmodule Core.Application do
  @moduledoc false

  use Application
  alias Core.Redis
  import Supervisor.Spec

  def start(_type, _args) do
    :telemetry.attach("log-handler", [:core, :repo, :query], &Core.TelemetryHandler.handle_event/4, nil)

    redis_config = Redis.config()

    children =
      Enum.map(0..(redis_config[:pool_size] - 1), fn connection_index ->
        worker(
          Redix,
          [
            [
              host: redis_config[:host],
              port: redis_config[:port],
              password: redis_config[:password],
              database: redis_config[:database],
              name: :"redis_#{connection_index}"
            ]
          ],
          id: {Redix, connection_index}
        )
      end)

    children = [{Core.Repo, []}] ++ children

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
