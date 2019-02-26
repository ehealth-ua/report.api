# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :capitation, Capitation.CapitationConsumer,
  max_demand: {:system, :integer, "CAPITATION_MAX_DEMAND", 500},
  capitation_validate_signature: {:system, :boolean, "CAPITATION_REPORT_VALIDATE_SIGNATURE", true}

config :capitation,
  worker: Capitation.Worker,
  stop?: {:system, :boolean, "CAPITATION_APP_STOP", true}

config :capitation, Capitation.Application, env: Mix.env()

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
