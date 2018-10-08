use Mix.Config

config :core, :environment, :test

# Configure your database
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "report_test",
  ownership_timeout: 120_000_000

config :core,
  api_resolvers: [
    media_storage: MediaStorageMock
  ]

# Run acceptance test in concurrent mode
config :core, sql_sandbox: true
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info
config :ex_unit, capture_log: true

config :core, Core.MediaStorage, endpoint: {:system, "MEDIA_STORAGE_ENDPOINT", "http://localhost:4040"}
