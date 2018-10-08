defmodule Core.Integration.DivisionStatsTest do
  @moduledoc false

  use Report.Web.ConnCase

  alias Core.Replica.Division
  alias Core.Replica.Employee
  alias Core.Stats.DivisionStats
  alias Core.Stats.DivisionsRequest
  alias Scrivener.Page

  describe "get_map_stats/1" do
    test "search clinics" do
      %{"division" => division} = insert_fixtures()

      params = %{
        name: division.name,
        type: DivisionsRequest.type(:clinic),
        east: 25,
        north: 45,
        west: 35,
        south: 55
      }

      {:ok, %Page{entries: map_stats}} = DivisionStats.get_map_stats(params)
      assert 1 == Enum.count(map_stats)

      id = division.id
      assert [%Division{id: ^id}] = map_stats

      {:ok, %Page{entries: []}} = DivisionStats.get_map_stats(Map.put(params, :page, 2))
    end

    test "search drugstores" do
      insert_fixtures()
      drugstore = DivisionsRequest.type(:drugstore)

      params = %{
        type: drugstore,
        east: 25,
        north: 45,
        west: 35,
        south: 55
      }

      {:ok, %Page{entries: map_stats}} = DivisionStats.get_map_stats(params)
      assert 1 == Enum.count(map_stats)

      assert [%Division{type: ^drugstore}] = map_stats

      {:ok, %Page{entries: []}} = DivisionStats.get_map_stats(Map.put(params, :page, 2))
    end
  end

  defp insert_fixtures do
    legal_entity = insert(:legal_entity)
    insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))

    params = [
      legal_entity_id: legal_entity.id,
      location: %Geo.Point{coordinates: {30.1233, 50.32423}},
      type: DivisionsRequest.type(:clinic),
      status: "ACTIVE",
      is_active: true,
      name: "test name"
    ]

    division = insert(:division, params)
    insert(:division, Keyword.put(params, :is_active, false))
    insert(:division, Keyword.put(params, :type, DivisionsRequest.type(:drugstore)))

    %{
      "division" => division,
      "legal_entity" => legal_entity
    }
  end
end
