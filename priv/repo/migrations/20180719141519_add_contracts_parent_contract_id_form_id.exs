defmodule Report.Repo.Migrations.AddContractsParentContractIdFormId do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:contracts) do
      add(:parent_contract_id, :uuid)
      add(:id_form, :string)
      add(:nhs_signed_date, :date)
    end
  end
end
