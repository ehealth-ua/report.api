defmodule ReportApi.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :report_api,
      version: "0.1.0",
      elixir: "~> 1.8.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {Report.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:confex_config_provider, "~> 0.1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.4.0"},
      {:eview, "~> 0.15.0"},
      {:libcluster, "~> 3.0", git: "https://github.com/AlexKovalevych/libcluster.git", branch: "kube_namespaces"},
      {:core, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      "ecto.setup": fn _ -> Mix.shell().cmd("cd ../core && mix ecto.setup") end
    ]
  end
end
