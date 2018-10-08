defmodule Report.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:distillery, "~> 2.0", runtime: false},
      {:excoveralls, "~> 0.9.1", only: [:dev, :test]},
      {:credo, "~> 0.9.3", only: [:dev, :test]}
    ]
  end
end
