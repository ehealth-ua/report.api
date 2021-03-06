defmodule ReportCache.Stats.MainStats do
  @moduledoc """
  Used to update main stats cache
  """

  use GenServer
  use Confex, otp_app: :report_cache
  alias ReportCache.Stats.Cache
  import Core.Stats.MainStats, only: [get_main_stats: 0]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    send(self(), :update_stats)
    {:ok, state}
  end

  def handle_info(:update_stats, state) do
    with {:ok, stats} <- get_main_stats() do
      Cache.set_main_stats(stats)
    end

    set_stats()
    {:noreply, state}
  end

  defp set_stats do
    Process.send_after(self(), :update_stats, config()[:cache_ttl])
  end
end
