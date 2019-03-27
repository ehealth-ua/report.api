use Mix.Config

config :core, Core.Repo,
  database: {:system, :string, "DB_NAME"},
  username: {:system, :string, "DB_USER"},
  password: {:system, :string, "DB_PASSWORD"},
  hostname: {:system, :string, "DB_HOST"},
  port: {:system, :integer, "DB_PORT"},
  pool_size: {:system, :integer, "DB_POOL_SIZE", 10},
  timeout: 15_000,
  types: Core.PostgresTypes
