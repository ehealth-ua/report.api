use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

environment :default do
  set(pre_start_hooks: "bin/hooks/")
  set(dev_mode: false)
  set(include_erts: true)
  set(include_src: false)

  set(
    overlays: [
      {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
    ]
  )
end

release :report_api do
  set(version: current_version(:report_api))

  set(
    applications: [
      report_api: :permanent
    ]
  )

  set(
    config_providers: [
      {Toml.Provider, [path: "/app/config.toml"]}
    ]
  )
end

release :capitation do
  set(version: current_version(:capitation))

  set(
    applications: [
      capitation: :permanent
    ]
  )

  set(
    config_providers: [
      {Toml.Provider, [path: "/app/config.toml"]}
    ]
  )
end
