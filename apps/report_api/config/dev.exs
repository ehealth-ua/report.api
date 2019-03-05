use Mix.Config

# Configuration for test environment

config :report_api, :environment, :dev

config :report_api, Report.Web.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :phoenix, :stacktrace_depth, 20
