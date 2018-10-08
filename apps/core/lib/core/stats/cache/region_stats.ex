defmodule Core.Stats.Cache.RegionStats do
  @moduledoc """
  Used to update region stats cache
  """

  use GenServer
  use Confex, otp_app: :core
  alias Core.Stats.Cache
  alias Core.Stats.MainStats

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    send(self(), :update_stats)
    {:ok, state}
  end

  def handle_info(:update_stats, state) do
    with {:ok, stats} <- MainStats.get_regions_stats() do
      Cache.set_regions_stats(stats)
    end

    set_stats()
    {:noreply, state}
  end

  defp set_stats do
    Process.send_after(self(), :update_stats, config()[:cache_ttl])
  end
end
