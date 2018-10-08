defmodule Report.Web.StatsView do
  @moduledoc false

  use Report.Web, :view

  @legal_entities_fields ~w(
    id
    name
    short_name
    public_name
    type
    position
    legal_form
    owner_property_type
    edrpou
    kveds
    addresses
    phones
    email
    mis_verified
    nhs_verified
  )a

  @employee_fields ~w(
    id
    position
    employee_type
  )a

  @party_fields ~w(
    id
    first_name
    last_name
    second_name
  )a

  def render("index.json", %{stats: nil}), do: %{}
  def render("index.json", %{stats: stats}), do: stats

  def render("index.json", %{"division" => division, "stats" => stats}) do
    %{
      "division" => render_one(division, __MODULE__, "division.json"),
      "stats" => render_one(stats, __MODULE__, "index.json")
    }
  end

  def render("regions.json", %{stats: regions}) when is_list(regions) do
    render_many(regions, __MODULE__, "region_stat.json")
  end

  def render("region_stat.json", %{stats: %{"region" => region, "stats" => stats}}) do
    %{
      "region" => render_one(region, __MODULE__, "region.json"),
      "stats" => render_one(stats, __MODULE__, "index.json")
    }
  end

  def render("division.json", %{stats: division}) do
    %{
      "id" => division.id,
      "name" => division.name
    }
  end

  def render("division_details.json", %{stats: division}) do
    %{
      "id" => division.id,
      "name" => division.name,
      "type" => division.type,
      "addresses" => division.addresses,
      "coordinates" => render_coordinates(division.location),
      "contacts" => %{
        "email" => division.email,
        "phones" => division.phones
      },
      "legal_entity" => render_one(division.legal_entity, __MODULE__, "legal_entity.json", as: :legal_entity),
      "working_hours" => division.working_hours
    }
  end

  def render("region.json", %{stats: region}) do
    %{
      "id" => region.id,
      "name" => region.name
    }
  end

  def render("region.json", stats) do
    stats
  end

  def render("legal_entity.json", %{legal_entity: legal_entity}) do
    legal_entity
    |> Map.take(@legal_entities_fields)
    |> render_legal_entity_owner(legal_entity)
  end

  def render("divisions.json", %{divisions: divisions}) do
    render_many(divisions, __MODULE__, "division_details.json")
  end

  defp render_legal_entity_owner(view, %{employees: [employee]}) do
    owner =
      employee
      |> Map.take(@employee_fields)
      |> Map.put(:party, Map.take(employee.party, @party_fields))

    Map.put(view, :owner, owner)
  end

  defp render_coordinates(%{coordinates: {longitude, latitude}}) do
    %{
      "latitude" => latitude,
      "longitude" => longitude
    }
  end

  defp render_coordinates(_) do
    %{
      "latitude" => nil,
      "longitude" => nil
    }
  end
end
