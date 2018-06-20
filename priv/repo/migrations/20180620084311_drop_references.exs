defmodule Report.Repo.Migrations.DropReferences do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:division_addresses) do
      modify(:division_id, :uuid, null: false)
    end

    alter table(:ingredients) do
      modify(:medication_child_id, :uuid)
      modify(:innm_child_id, :uuid)
      modify(:parent_id, :uuid, null: false)
    end
  end
end
