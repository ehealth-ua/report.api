use Mix.Config

config :capitation, :environment, :test

config :capitation,
  worker: WorkerMock,
  stop?: {:system, :boolean, "CAPITATION_APP_STOP", false}

# Run acceptance test in concurrent mode
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info
config :ex_unit, capture_log: true
