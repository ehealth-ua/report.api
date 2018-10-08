defmodule Capitation.Worker do
  @moduledoc false

  use GenServer
  alias Capitation.API
  use Confex, otp_app: :capitation

  @behaviour Capitation.Behaviours.WorkerBehaviour

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(state) do
    Process.send_after(self(), :run, 10)
    {:ok, state}
  end

  @impl true
  def handle_info(:run, state) do
    API.run()
    {:noreply, state}
  end

  @impl true
  def stop_application do
    System.halt(0)
  end
end
