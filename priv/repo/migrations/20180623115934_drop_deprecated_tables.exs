defmodule Report.Repo.Migrations.DropDeprecatedTables do
  @moduledoc false

  use Ecto.Migration

  def change do
    drop(table(:billings))
    drop(table(:billing_logs))
    drop(table(:report_logs))
    drop(table(:red_msps_territories))
  end
end
