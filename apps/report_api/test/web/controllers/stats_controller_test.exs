defmodule Report.Web.StatsControllerTest do
  @moduledoc false

  use Report.Web.ConnCase
  alias Core.Replica.Employee
  alias Core.Stats.HistogramStatsRequest
  alias Ecto.UUID
  alias NExJsonSchema.Validator
  import Report.Web.Router.Helpers

  test "get main stats", %{conn: conn} do
    expect_get_main_stats()
    conn = get(conn, stats_path(conn, :index))

    schema =
      "test/data/stats/main_stats_response.json"
      |> File.read!()
      |> Poison.decode!()

    :ok = Validator.validate(schema, json_response(conn, 200))
  end

  test "get division stats", %{conn: conn} do
    assert_raise(Ecto.NoResultsError, fn ->
      get(conn, stats_path(conn, :division, UUID.generate()))
    end)

    division = insert(:division)
    conn = get(conn, stats_path(conn, :division, division.id))

    schema =
      "test/data/stats/division_stats_response.json"
      |> File.read!()
      |> Poison.decode!()

    :ok = Validator.validate(schema, json_response(conn, 200))
  end

  test "get regions stats", %{conn: conn} do
    expect_get_regions_stats(2)

    schema =
      "test/data/stats/regions_stats_response.json"
      |> File.read!()
      |> Poison.decode!()

    conn = get(conn, stats_path(conn, :regions))
    :ok = Validator.validate(schema, json_response(conn, 200))

    insert(:region)
    conn = get(conn, stats_path(conn, :regions))
    :ok = Validator.validate(schema, json_response(conn, 200))
  end

  test "get histogram stats", %{conn: conn} do
    expect_get_histogram_stats(2)

    conn =
      get(
        conn,
        stats_path(
          conn,
          :histogram,
          from_date: "2017-01-01",
          to_date: "2017-07-01",
          interval: HistogramStatsRequest.interval(:day)
        )
      )

    assert response(conn, 200)

    conn =
      get(
        conn,
        stats_path(
          conn,
          :histogram,
          from_date: Timex.now() |> Timex.shift(days: -5) |> Timex.format!("%F", :strftime),
          to_date: to_string(Date.utc_today()),
          interval: HistogramStatsRequest.interval(:day)
        )
      )

    schema =
      "test/data/stats/histogram_stats_response.json"
      |> File.read!()
      |> Poison.decode!()

    :ok = Validator.validate(schema, json_response(conn, 200))
  end

  describe "get divisions" do
    test "validate schema response", %{conn: conn} do
      legal_entity = insert(:legal_entity)
      insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))
      insert(:division, legal_entity: legal_entity)

      resp =
        conn
        |> get(stats_path(conn, :divisions))
        |> json_response(200)

      schema =
        "test/data/stats/divisions_response.json"
        |> File.read!()
        |> Poison.decode!()

      :ok = Validator.validate(schema, resp)
    end

    test "filter divisions by id", %{conn: conn} do
      legal_entity = insert(:legal_entity)
      insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))
      insert(:division, legal_entity: legal_entity)
      %{id: division_id} = insert(:division, legal_entity: legal_entity)

      assert [%{"id" => ^division_id}] =
               conn
               |> get(stats_path(conn, :divisions, id: division_id))
               |> json_response(200)
               |> Map.get("data")
    end

    test "get divisions map stats", %{conn: conn} do
      conn = get(conn, stats_path(conn, :divisions))
      assert response(conn, 200)

      conn =
        get(
          conn,
          stats_path(
            conn,
            :divisions,
            north: "50.32423",
            east: "30.1233",
            south: "50.32423"
          )
        )

      assert response(conn, 422)

      conn =
        get(
          conn,
          stats_path(
            conn,
            :divisions,
            north: "invalid",
            east: "50.32423",
            south: "50.32423",
            west: "50.32423"
          )
        )

      assert response(conn, 422)

      conn =
        get(
          conn,
          stats_path(
            conn,
            :divisions,
            north: "50.32423",
            east: "30.1233",
            south: "50.32423",
            west: "50.32423"
          )
        )

      assert response(conn, 200)

      conn =
        get(
          conn,
          stats_path(
            conn,
            :divisions,
            type: "invalid",
            north: "50.32423",
            east: "30.1233",
            south: "50.32423",
            west: "50.32423"
          )
        )

      assert response(conn, 422)

      insert_fixtures()

      conn =
        get(
          conn,
          stats_path(
            conn,
            :divisions,
            north: 45,
            east: 35,
            south: 55,
            west: 25,
            page_size: 3
          )
        )

      assert map_stats = response(conn, 200)
      map_stats = Poison.decode!(map_stats)

      schema =
        "test/data/stats/divisions_response.json"
        |> File.read!()
        |> Poison.decode!()

      :ok = Validator.validate(schema, map_stats)

      assert 3 == Enum.count(map_stats["data"])
      assert is_map(map_stats["paging"])
      assert 2 == map_stats["paging"]["total_pages"]
      assert 3 == map_stats["paging"]["page_size"]
      assert 4 == map_stats["paging"]["total_entries"]
    end

    test "search divisions by location", %{conn: conn} do
      legal_entity = insert(:legal_entity)
      insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))

      location1 = %Geo.Point{coordinates: {30.512653, 50.469034}}
      location2 = %Geo.Point{coordinates: {30.515710, 50.468802}}
      location3 = %Geo.Point{coordinates: {30.520335, 50.466036}}
      division1 = insert(:division, legal_entity: legal_entity, location: location1)
      division2 = insert(:division, legal_entity: legal_entity, location: location2)
      insert(:division, legal_entity: legal_entity, location: location3)

      params = %{
        "east" => 30.509370,
        "north" => 50.471165,
        "west" => 30.517845,
        "south" => 50.466781
      }

      conn1 = get(conn, stats_path(conn, :divisions), params)
      resp = json_response(conn1, 200)["data"]

      assert 2 == length(resp)

      Enum.each(resp, fn %{"id" => id} ->
        assert id in [division1.id, division2.id]
      end)
    end

    test "search divisions by legal entity name and edrpou", %{conn: conn} do
      legal_entity = insert(:legal_entity, name: "У Михалыча", edrpou: "10020030")
      insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))
      division1 = insert(:division, legal_entity: legal_entity)

      legal_entity2 = insert(:legal_entity, name: "Синяк", edrpou: "20030040")
      insert(:employee, legal_entity: legal_entity2, employee_type: Employee.type(:owner))
      division2 = insert(:division, legal_entity: legal_entity2)

      params = %{legal_entity_name: legal_entity.name, legal_entity_edrpou: legal_entity.edrpou}

      resp =
        conn
        |> get(stats_path(conn, :divisions), params)
        |> json_response(200)
        |> Map.get("data")

      assert 1 == length(resp)
      assert division1.id == hd(resp)["id"]

      # name and edrpou from different legal entitites
      params = %{legal_entity_name: legal_entity.name, legal_entity_edrpou: legal_entity2.edrpou}

      assert [] ==
               conn
               |> get(stats_path(conn, :divisions), params)
               |> json_response(200)
               |> Map.get("data")

      params = %{legal_entity_name: legal_entity2.name, legal_entity_edrpou: legal_entity2.edrpou}

      resp =
        conn
        |> get(stats_path(conn, :divisions), params)
        |> json_response(200)
        |> Map.get("data")

      assert 1 == length(resp)
      assert division2.id == hd(resp)["id"]

      # name and edrpou from different legal entitites
      params = %{legal_entity_name: legal_entity2.name, legal_entity_edrpou: legal_entity.edrpou}

      assert [] ==
               conn
               |> get(stats_path(conn, :divisions), params)
               |> json_response(200)
               |> Map.get("data")
    end

    test "search divisions by address", %{conn: conn} do
      legal_entity = insert(:legal_entity)
      insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))

      division1 = insert(:division, legal_entity: legal_entity, addresses: [])

      insert(:division_address, %{
        division_id: division1.id,
        type: "REGISTRATION",
        area: "Одеська",
        region: "Бердичівський",
        settlement: "Одеса"
      })

      insert(:division_address, %{
        division_id: division1.id,
        type: "RESIDENCE",
        area: "Київська",
        region: "Київський",
        settlement: "Київ"
      })

      division2 = insert(:division, legal_entity: legal_entity, addresses: [])

      insert(:division_address, %{
        division_id: division2.id,
        type: "REGISTRATION",
        area: "Львівська",
        region: "Жмеринковський",
        settlement: "Солотвино"
      })

      insert(:division_address, %{
        division_id: division2.id,
        type: "RESIDENCE",
        area: "Київська",
        region: "Броварський",
        settlement: "Бровари"
      })

      division3 = insert(:division, legal_entity: legal_entity, addresses: [])

      insert(:division_address, %{
        division_id: division3.id,
        type: "REGISTRATION",
        area: "Київська",
        region: "Київський",
        settlement: "Київ"
      })

      insert(:division_address, %{
        division_id: division3.id,
        type: "RESIDENCE",
        area: "Польтавська",
        region: "Броварський",
        settlement: "Лубни"
      })

      # By all address params
      params = %{area: "Київська", region: "Київський", settlement: "Київ"}

      resp =
        conn
        |> get(stats_path(conn, :divisions), params)
        |> json_response(200)
        |> Map.get("data")

      assert 1 == length(resp)
      assert division1.id == hd(resp)["id"]

      # search by area. Assert that division with registration area "Київська" not in response
      params = %{area: "Київська"}

      resp =
        conn
        |> get(stats_path(conn, :divisions), params)
        |> json_response(200)
        |> Map.get("data")

      assert 2 == length(resp)

      Enum.each(resp, fn %{"id" => id} ->
        assert id in [division1.id, division2.id]
      end)

      # search by region
      params = %{region: "Броварський"}

      resp =
        conn
        |> get(stats_path(conn, :divisions), params)
        |> json_response(200)
        |> Map.get("data")

      assert 2 == length(resp)

      Enum.each(resp, fn %{"id" => id} ->
        assert id in [division2.id, division3.id]
      end)

      # search by settlement
      params = %{settlement: "Лубни"}

      resp =
        conn
        |> get(stats_path(conn, :divisions), params)
        |> json_response(200)
        |> Map.get("data")

      assert 1 == length(resp)
      assert division3.id == hd(resp)["id"]

      # Not Found
      params = %{area: "Київська", settlement: "Лубни"}

      assert [] =
               conn
               |> get(stats_path(conn, :divisions), params)
               |> json_response(200)
               |> Map.get("data")
    end
  end

  defp insert_fixtures do
    legal_entity = insert(:legal_entity)
    insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner))
    insert(:employee, legal_entity: legal_entity, employee_type: Employee.type(:owner), is_active: false)
    insert(:division, location: %Geo.Point{coordinates: {30.1233, 50.32423}}, legal_entity: legal_entity)
    insert(:division, location: %Geo.Point{coordinates: {30.1233, 50.32423}}, legal_entity: legal_entity)
    insert(:division, location: %Geo.Point{coordinates: {30.1233, 50.32423}}, legal_entity: legal_entity)
    insert(:division, location: %Geo.Point{coordinates: {30.1233, 50.32423}}, legal_entity: legal_entity)
  end
end
