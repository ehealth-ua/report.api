defmodule Report.Replica.DivisionAddress do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "division_addresses" do
    field(:zip, :string)
    field(:area, :string)
    field(:type, :string)
    field(:region, :string)
    field(:street, :string)
    field(:country, :string)
    field(:building, :string)
    field(:apartment, :string)
    field(:settlement, :string)
    field(:street_type, :string)
    field(:settlement_id, Ecto.UUID)
    field(:settlement_type, :string)

    belongs_to(:division, Report.Replica.Division, foreign_key: :division_id, type: Ecto.UUID)
  end
end