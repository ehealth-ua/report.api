defmodule Report.Repo.Migrations.DropReferences do
  @moduledoc false

  use Ecto.Migration

  def change do
    drop(constraint(:division_addresses, "division_addresses_division_id_fkey"))
    drop(constraint(:ingredients, "ingredients_innm_child_id_fkey"))
    drop(constraint(:ingredients, "ingredients_medication_child_id_fkey"))
    drop(constraint(:ingredients, "ingredients_parent_id_fkey"))
  end
end
