defmodule Report.Employees.Search do
  @moduledoc false

  use Ecto.Schema

  schema "employees_search" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:second_name, :string)
    field(:speciality, :string)
    field(:region, :string)
    field(:area, :string)
    field(:settlement, :string)
    field(:division_name, :string)
  end
end
