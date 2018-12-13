defmodule ReportCache.Rpc do
  @moduledoc false

  alias ReportCache.Stats.Cache

  def get_main_stats do
    Cache.get_main_stats()
  end

  def get_regions_stats do
    Cache.get_regions_stats()
  end

  def get_histogram_stats do
    Cache.get_histogram_stats()
  end
end
