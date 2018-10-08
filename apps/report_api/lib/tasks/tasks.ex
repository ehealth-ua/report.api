defmodule Report.ReleaseTasks do
  @moduledoc """
  Nice way to apply migrations inside a released application.

  Example:

      report/bin/report command Elixir.Core.ReleaseTasks migrate
  """

  alias Ecto.Migration.Runner
  alias Ecto.Migrator

  @repo Core.Repo

  def migrate do
    migrations_dir = Application.app_dir(:core, "priv/repo/migrations")

    # Run migrations
    @repo
    |> start_repo
    |> Migrator.run(migrations_dir, :up, all: true)

    # Signal shutdown
    IO.puts("Success!")
    :init.stop()
  end

  defp start_repo(repo) do
    start_applications([:logger, :postgrex, :ecto])
    Application.load(:report_api)
    # If you don't include Repo in application supervisor start it here manually
    repo.start_link()
    repo
  end

  defp start_applications(apps) do
    Enum.each(apps, fn app ->
      {_, _message} = Application.ensure_all_started(app)
    end)
  end
end
