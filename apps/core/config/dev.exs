use Mix.Config

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
  loggers: [{EhealthLogger.Ecto, :log, [:info]}]
