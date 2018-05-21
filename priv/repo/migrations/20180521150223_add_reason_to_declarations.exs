defmodule Report.Repo.Migrations.AddReasonToDeclarations do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:declarations) do
      add(:reason, :string)
    end
  end
end
