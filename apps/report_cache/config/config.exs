use Mix.Config

config :report_cache, ReportCache.Stats.MainStats, cache_ttl: {:system, :integer, "MAIN_STATS_CACHE_TTL", 60_000}

config :report_cache, ReportCache.Stats.RegionStats, cache_ttl: {:system, :integer, "REGIONS_STATS_CACHE_TTL", 60_000}

config :report_cache, ReportCache.Stats.HistogramStats,
  cache_ttl: {:system, :integer, "HISTOGRAM_STATS_CACHE_TTL", 60_000}

import_config "#{Mix.env()}.exs"
