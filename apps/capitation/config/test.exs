use Mix.Config

config :capitation, :environment, :test

config :capitation,
  worker: WorkerMock,
  stop?: {:system, :boolean, "CAPITATION_APP_STOP", false}
