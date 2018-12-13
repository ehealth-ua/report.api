defmodule ReportCache.Stats.HistogramStats do
  @moduledoc """
  Used to update histogram stats cache
  """

  use GenServer
  use Confex, otp_app: :report_cache
  use Timex
  alias Core.Stats.HistogramStatsRequest
  alias Core.Stats.MainStats
  alias ReportCache.Stats.Cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    send(self(), :update_stats)
    {:ok, state}
  end

  def handle_info(:update_stats, state) do
    to_date = Timex.now()
    from_date = Timex.shift(to_date, days: -30)

    with {:ok, stats} <-
           MainStats.get_histogram_stats(%{
             "from_date" => Timex.format!(from_date, "{ISOdate}"),
             "to_date" => Timex.format!(to_date, "{ISOdate}"),
             "interval" => HistogramStatsRequest.interval(:day)
           }) do
      Cache.set_histogram_stats(stats)
    end

    set_stats()
    {:noreply, state}
  end

  defp set_stats do
    Process.send_after(self(), :update_stats, config()[:cache_ttl])
  end
end
