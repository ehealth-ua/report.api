defmodule Report.Scheduler do
  @moduledoc false

  use Quantum.Scheduler, otp_app: :report_api

  alias Crontab.CronExpression.Parser
  alias Quantum.Job
  alias Report.Capitation

  def create_jobs do
    __MODULE__.new_job()
    |> Job.set_name(:capitation)
    |> Job.set_overlap(false)
    |> Job.set_schedule(Parser.parse!(get_config()[:capitation_schedule]))
    |> Job.set_task(&Capitation.run/0)
    |> __MODULE__.add_job()
  end

  defp get_config do
    Confex.fetch_env!(:report_api, __MODULE__)
  end
end
