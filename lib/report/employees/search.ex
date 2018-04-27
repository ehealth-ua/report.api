defmodule Report.Employees.Search do
  @moduledoc false

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:id, Ecto.UUID)
    field(:full_name, :string)
    field(:speciality, :string)
    field(:division_id, Ecto.UUID)
    field(:division_name, :string)
    field(:area, :string)
    field(:region, :string)
    field(:settlement, :string)
    field(:is_available, :boolean)
  end
end
