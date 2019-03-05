# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :report_api, Report.Web.Endpoint,
  url: [host: "localhost"],
  load_from_system_env: true,
  secret_key_base: "U6jv7YneKVixSMz0h4Z/W1P5gifuhS0rekLu2tuZRsZmE856L71BcjX18tNzZmVu",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)],
  instrumenters: [LoggerJSON.Phoenix.Instruments]

import_config "#{Mix.env()}.exs"
