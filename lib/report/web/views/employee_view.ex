defmodule Report.Web.EmployeeView do
  @moduledoc false

  use Report.Web, :view
  alias Report.Replica.Division
  alias Report.Replica.Party

  def render("index.json", %{paging: paging}) do
    render_many(paging.entries, __MODULE__, "show.json", as: :employee)
  end

  def render("show.json", %{employee: employee}) do
    employee
    |> Map.take(~w(
      id
      position
      status
      employee_type
      start_date
      end_date
      speciality
    )a)
    |> render_association(employee.party)
    |> render_association(employee.division)
    |> Map.put(:speciality, get_employee_specialities(employee))
  end

  defp render_association(map, %Party{} = party) do
    data =
      party
      |> Map.take(~w(
        id
        first_name
        last_name
        second_name
        birth_date
        gender
        tax_id
        no_tax_id
        documents
        phones
        about_myself
        working_experience
      )a)
      |> Map.put(:is_available, party.declaration_count < party.declaration_limit)

    Map.put(map, :party, data)
  end

  defp render_association(map, %Division{} = division) do
    data = Map.take(division, ~w(
      id
      name
      status
      type
      legal_entity_id
      mountain_group
    )a)
    Map.put(map, :division, data)
  end

  defp render_association(map, _), do: map

  defp get_employee_specialities(employee) do
    speciality = employee.speciality
    party_specialities = employee.party.specialities || []

    party_specialities =
      party_specialities
      |> Enum.filter(&(Map.get(&1, "speciality") != speciality["speciality"]))
      |> Enum.map(&Map.put(&1, "speciality_officio", false))

    case speciality do
      nil -> party_specialities
      speciality -> [speciality | party_specialities]
    end
  end
end
