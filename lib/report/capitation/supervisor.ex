defmodule Report.Capitation.GenStageSupervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: {:via, Registry, {:capitation_registry, "supervisor"}})
  end

  def init(_) do
    children = [
      worker(Report.Capitation.Cache, []),
      worker(Report.Capitation.CapitationProducer, [0]),
      worker(Report.Capitation.CapitationConsumer, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
