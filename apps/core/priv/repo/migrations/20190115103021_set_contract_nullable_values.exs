defmodule Core.Repo.Migrations.SetContractNullableValues do
  use Ecto.Migration

  def change do
    alter table(:contracts) do
      modify(:contractor_rmsp_amount, :integer, null: true)
      modify(:nhs_contract_price, :float, null: true)
    end
  end
end
