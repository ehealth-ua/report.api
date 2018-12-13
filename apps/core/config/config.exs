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
#     config :core, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:core, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"
config :core,
  namespace: Core,
  ecto_repos: [Core.Repo],
  environment: Mix.env()

config :core, Core.Rpc.Worker, max_attempts: {:system, :integer, "RPC_MAX_ATTEMPTS", 3}

# Configure your database
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "report_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  ownership_timeout: :infinity,
  pool_size: 20,
  types: Core.PostgresTypes,
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

# This configuration file is loaded before any dependency and
# is restricted to this project.

config :ssl, protocol_version: :"tlsv1.2"

# Configures Elixir's Logger
config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

config :core, Core.MediaStorage,
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

config :core,
  api_resolvers: [
    media_storage: Core.MediaStorage
  ],
  rpc_worker: Core.Rpc.Worker

config :core,
  topologies: [
    k8s_report_cache: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "report_cache",
        kubernetes_selector: "app=cache",
        kubernetes_namespace: "reports",
        polling_interval: 10_000
      ]
    ]
  ]

import_config "#{Mix.env()}.exs"
