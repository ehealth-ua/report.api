defmodule Report.Repo.Migrations.AddDispensedBy do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:medication_dispenses) do
      add(:dispensed_by, :string)
    end
  end
end
