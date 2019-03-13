use Mix.Config

# Configure your database
config :core, Core.Repo,
  username: "postgres",
  database: "report_test",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  types: Core.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 120_000_000

config :core,
  api_resolvers: [
    media_storage: MediaStorageMock
  ],
  rpc_worker: RpcWorkerMock

# Run acceptance test in concurrent mode
config :core, sql_sandbox: true
config :logger, level: :warn
config :ex_unit, capture_log: true

config :core, Core.MediaStorage, endpoint: {:system, "MEDIA_STORAGE_ENDPOINT", "http://localhost:4040"}
