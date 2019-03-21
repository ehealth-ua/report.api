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
      to_date = Timex.end_of_month(Timex.now())
      from_date = to_date |> Timex.shift(months: -12) |> Timex.beginning_of_month()

      MainStats.get_histogram_stats(%{
        "from_date" => from_date,
        "to_date" => to_date,
        "interval" => HistogramStatsRequest.interval(:month)
      })
    end)
  end
end
