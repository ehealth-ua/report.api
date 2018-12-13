defmodule Core.Expectations.Rpc do
  @moduledoc false

  import Mox
  alias Core.Stats.HistogramStatsRequest
  alias Core.Stats.MainStats

  def expect_get_main_stats(times \\ 1) do
    expect(RpcWorkerMock, :run, times, fn _, _, :get_main_stats, _ ->
      MainStats.get_main_stats()
    end)
  end

  def expect_get_regions_stats(times \\ 1) do
    expect(RpcWorkerMock, :run, times, fn _, _, :get_regions_stats, _ ->
      MainStats.get_regions_stats()
    end)
  end

  def expect_get_histogram_stats(times \\ 1) do
    expect(RpcWorkerMock, :run, times, fn _, _, :get_histogram_stats, _ ->
      to_date = Timex.now()
      from_date = Timex.shift(to_date, days: -30)

      MainStats.get_histogram_stats(%{
        "from_date" => Timex.format!(from_date, "{ISOdate}"),
        "to_date" => Timex.format!(to_date, "{ISOdate}"),
        "interval" => HistogramStatsRequest.interval(:day)
      })
    end)
  end
end
