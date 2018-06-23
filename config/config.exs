# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :report_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:report_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"
config :report_api, ecto_repos: [Report.Repo]

# Configure your database
config :report_api, Report.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME", "report_dev"},
  username: {:system, "DB_USER", "postgres"},
  password: {:system, "DB_PASSWORD", "postgres"},
  hostname: {:system, "DB_HOST", "localhost"},
  port: {:system, :integer, "DB_PORT", 5432},
  ownership_timeout: :infinity,
  pool_size: 20,
  types: Report.PostgresTypes,
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
# Configures the endpoint
config :report_api, Report.Web.Endpoint,
  url: [host: "localhost"],
  load_from_system_env: true,
  secret_key_base: "U6jv7YneKVixSMz0h4Z/W1P5gifuhS0rekLu2tuZRsZmE856L71BcjX18tNzZmVu",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

config :ssl, protocol_version: :"tlsv1.2"

# Configures Elixir's Logger
config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

config :report_api, Report.MediaStorage,
  endpoint: {:system, "MEDIA_STORAGE_ENDPOINT", "http://api-svc.ael"},
  # endpoint: {:system, "MEDIA_STORAGE_ENDPOINT", "http://0.0.0.0:64927"},
  capitation_report_bucket: {:system, "MEDIA_STORAGE_CAPITATION_REPORT_BUCKET", "capitation-reports-dev"},
  declarations_bucket: {:system, "MEDIA_STORAGE_DECLARATIONS_BUCKET", "declarations-dev"},
  enabled?: {:system, :boolean, "MEDIA_STORAGE_ENABLED", false},
  hackney_options: [
    connect_timeout: {:system, :integer, "MEDIA_STORAGE_REQUEST_TIMEOUT", 30_000},
    recv_timeout: {:system, :integer, "MEDIA_STORAGE_REQUEST_TIMEOUT", 30_000},
    timeout: {:system, :integer, "MEDIA_STORAGE_REQUEST_TIMEOUT", 30_000}
  ]

config :report_api,
  api_resolvers: [
    media_storage: Report.MediaStorage
  ]

config :report_api, Report.Stats.Cache.MainStats, cache_ttl: {:system, :integer, "MAIN_STATS_CACHE_TTL", 60_000}

config :report_api, Report.Stats.Cache.RegionStats, cache_ttl: {:system, :integer, "REGIONS_STATS_CACHE_TTL", 60_000}

config :report_api, Report.Stats.Cache.HistogramStats,
  cache_ttl: {:system, :integer, "HISTOGRAM_STATS_CACHE_TTL", 60_000}

config :report_api, Report.Stats.MainStats,
  declarations_by_regions_timeout: {:system, :integer, "DECLARATIONS_BY_REGIONS_TIMEOUT", 60_000 * 5}

config :report_api, Report.Scheduler, capitation_schedule: {:system, :string, "CAPITATION_SCHEDULE", "0 * 1 * *"}

config :report_api, Report.Capitation.CapitationConsumer,
  max_demand: {:system, :integer, "CAPITATION_MAX_DEMAND", 500},
  capitation_validate_signature: {:system, :boolean, "CAPITATION_REPORT_VALIDATE_SIGNATURE", true}

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
