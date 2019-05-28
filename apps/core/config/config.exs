# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :core,
  namespace: Core,
  ecto_repos: [Core.Repo],
  environment: Mix.env()

config :core, Core.Rpc.Worker, max_attempts: {:system, :integer, "RPC_MAX_ATTEMPTS", 3}

config :ssl, protocol_version: :"tlsv1.2"

config :logger_json, :backend,
  formatter: EhealthLogger.Formatter,
  metadata: :all

config :logger,
  backends: [LoggerJSON],
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

config :core, :cache, list_reimbursement_report_ttl: {:system, :integer, "LIST_REIMBURSEMENT_REPORT_TTL", 60 * 60}

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

config :core, Core.Redis,
  host: {:system, "REDIS_HOST", "0.0.0.0"},
  port: {:system, :integer, "REDIS_PORT", 6379},
  password: {:system, "REDIS_PASSWORD", nil},
  database: {:system, "REDIS_DATABASE", nil},
  pool_size: {:system, :integer, "REDIS_POOL_SIZE", 5}

import_config "#{Mix.env()}.exs"
