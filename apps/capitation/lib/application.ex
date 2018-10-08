defmodule Capitation.Application do
  @moduledoc """
  This is an entry point of report application.
  """
  use Application
  use Confex, otp_app: :capitation
  alias Confex.Resolver

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # import Supervisor.Spec, warn: false

    children =
      if config()[:env] == :test,
        do: [],
        else: [
          {Capitation.Cache, []},
          {Capitation.CapitationProducer, 0},
          {Capitation.CapitationConsumer, []},
          {Capitation.Worker, []}
        ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Capitation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Loads configuration in `:init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def init(_key, config), do: {:ok, Resolver.resolve!(config)}
end
