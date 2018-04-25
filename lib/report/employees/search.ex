defmodule Report.Employees.Search do
  @moduledoc false

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:id, Ecto.UUID)
    field(:full_name, :string)
    field(:speciality, :string)
    field(:region, :string)
    field(:area, :string)
    field(:settlement, :string)
    field(:division_name, :string)
    field(:is_available, :boolean)
  end
end
