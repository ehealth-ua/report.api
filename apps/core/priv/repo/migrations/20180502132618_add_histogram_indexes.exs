defmodule Core.Repo.Migrations.AddHistogramIndexes do
  @moduledoc false

  use Ecto.Migration

  def change do
    create(index(:declarations, [:inserted_at]))
    create(index(:medication_requests, [:inserted_at]))
  end
end
