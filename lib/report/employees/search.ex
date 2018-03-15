defmodule Report.Employees.Search do
  @moduledoc false

  use Ecto.Schema

  schema "employees_search" do
    field(:full_name, :string)
    field(:speciality, :string)
    field(:region, :string)
    field(:area, :string)
    field(:settlement, :string)
    field(:division_name, :string)
    field(:is_available, :boolean, default: true)
  end
end
