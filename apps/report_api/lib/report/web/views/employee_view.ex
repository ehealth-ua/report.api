defmodule Report.Web.EmployeeView do
  @moduledoc false

  use Report.Web, :view
  alias Core.Replica.Division
  alias Core.Replica.LegalEntity
  alias Core.Replica.Party
  alias Core.Repo

  def render("index.json", %{paging: paging}) do
    render_many(paging.entries, __MODULE__, "list_item.json", as: :employee)
  end

  def render("list_item.json", %{employee: employee}) do
    employee
    |> Map.take(~w(
      id
    )a)
    |> render_association_list(employee.party, employee.speciality)
    |> render_association_list(employee.division)
    |> render_association(employee.legal_entity)
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
    )a)
    |> render_association(employee.party, employee.speciality)
    |> render_association(employee.division)
    |> render_association(employee.legal_entity)
  end

  defp render_association(map, %Party{} = party, employee_speciality) do
    specialities = party.specialities || []

    party_specialities =
      specialities
      |> Enum.map(&Map.put(&1, "speciality_officio", false))
      |> Enum.filter(&(Map.get(&1, "speciality") != employee_speciality["speciality"]))

    specialities =
      [employee_speciality | party_specialities]
      |> Enum.filter(&(!is_nil(&1)))

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
        working_experience
        educations
        qualifications
        science_degree
        about_myself
      )a)
      |> Map.put(:is_available, (party.declaration_count || 0) < party.declaration_limit)
      |> Map.put(:specialities, specialities)

    Map.put(map, :party, data)
  end

  defp render_association(map, %Division{} = division) do
    division = Repo.preload(division, :addresses)

    data =
      division
      |> Map.take(~w(
        id
        name
        type
      )a)
      |> Map.put(:addresses, Enum.find(division.addresses, &(Map.get(&1, :type) == "RESIDENCE")))

    Map.put(map, :division, render_association(data, division.legal_entity))
  end

  defp render_association(map, %LegalEntity{} = legal_entity) do
    data = Map.take(legal_entity, ~w(id name)a)
    Map.put(map, :legal_entity, data)
  end

  defp render_association(map, _), do: map

  defp render_association_list(map, %Party{} = party, employee_speciality) do
    specialities = party.specialities || []

    party_specialities =
      specialities
      |> Enum.map(&Map.put(&1, "speciality_officio", false))
      |> Enum.filter(&(Map.get(&1, "speciality") != employee_speciality["speciality"]))

    specialities =
      [employee_speciality | party_specialities]
      |> Enum.filter(&(!is_nil(&1)))

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
      )a)
      |> Map.put(:is_available, (party.declaration_count || 0) < party.declaration_limit)
      |> Map.put(:specialities, specialities)

    Map.put(map, :party, data)
  end

  defp render_association_list(map, %Division{} = division) do
    division = Repo.preload(division, :addresses)

    data =
      division
      |> Map.take(~w(
        id
        name
      )a)
      |> Map.put(:addresses, Enum.find(division.addresses, &(Map.get(&1, :type) == "RESIDENCE")))

    Map.put(map, :division, render_association(data, division.legal_entity))
  end
end
