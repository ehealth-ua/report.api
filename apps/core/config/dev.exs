use Mix.Config

# Configure your database
config :core, Core.Repo,
  database: "report_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  ownership_timeout: :infinity,
  pool_size: 20,
  types: Core.PostgresTypes
