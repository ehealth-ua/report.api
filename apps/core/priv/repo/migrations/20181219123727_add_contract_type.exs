defmodule Core.Repo.Migrations.AddContractType do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:contracts) do
      add(:type, :string)
    end
  end
end
