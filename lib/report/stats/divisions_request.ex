defmodule Report.Stats.DivisionsRequest do
  @moduledoc false

  use Ecto.Schema

  @primary_key false

  @type_clinic "CLINIC"
  @type_ambulant "AMBULANT_CLINIC"
  @type_fap "FAP"
  @type_drugstore "DRUGSTORE"
  @type_drugstore_point "DRUGSTORE_POINT"

  embedded_schema do
    field(:id, Ecto.UUID)
    field(:type, :string)
    field(:name, :string)
    field(:area, :string)
    field(:region, :string)
    field(:settlement, :string)
    field(:legal_entity_id, Ecto.UUID)
    field(:legal_entity_name, :string)
    field(:legal_entity_edrpou, :string)
    field(:north, :float)
    field(:east, :float)
    field(:south, :float)
    field(:west, :float)
  end

  def type(:clinic), do: @type_clinic
  def type(:ambulant), do: @type_ambulant
  def type(:fap), do: @type_fap
  def type(:drugstore), do: @type_drugstore
  def type(:drugstore_point), do: @type_drugstore_point

  def types do
    Enum.map(~w(clinic ambulant fap drugstore drugstore_point)a, &type/1)
  end
end
