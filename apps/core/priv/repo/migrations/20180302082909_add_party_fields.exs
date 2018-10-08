defmodule Core.Repo.Migrations.AddPartyFields do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:parties) do
      add(:educations, :jsonb)
      add(:qualifications, :jsonb)
      add(:specialities, :jsonb)
      add(:science_degree, :jsonb)
      add(:declaration_limit, :integer)
    end
  end
end
