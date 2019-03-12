defmodule Core.Repo.Migrations.AboutMyselfText do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:parties) do
      modify(:about_myself, :text)
    end
  end
end
