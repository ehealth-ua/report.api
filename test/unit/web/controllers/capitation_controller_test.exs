defmodule Report.CapitationControllerTest do
  @moduledoc false

  use Report.Web.ConnCase

  describe "List capitation reports" do
    test "success", %{conn: conn} do
      %{id: id1} = insert(:capitation_report)
      %{id: id2} = insert(:capitation_report)

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page_size" => "1"}))
        |> json_response(200)

      assert %{"data" => [%{"id" => response_id1}], "paging" => %{"page_number" => 1, "page_size" => 1}} = response
      assert response_id1 in [id1, id2]

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page" => "2", "page_size" => "1"}))
        |> json_response(200)

      assert %{"data" => [%{"id" => response_id2}], "paging" => %{"page_number" => 2, "page_size" => 1}} = response
      assert response_id2 != response_id1
      assert response_id2 in [id1, id2]
    end

    test "limit list page size", %{conn: conn} do
      insert(:capitation_report)

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page_size" => "500"}))
        |> json_response(200)

      assert %{"paging" => %{"page_number" => 1, "page_size" => 100}} = response
    end

    test "default list page size", %{conn: conn} do
      insert(:capitation_report)

      response =
        conn
        |> get(capitation_path(conn, :index))
        |> json_response(200)

      assert %{"paging" => %{"page_number" => 1, "page_size" => 50}} = response
    end

    test "return page on invalid params", %{conn: conn} do
      insert(:capitation_report)

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page" => "aaa", "page_size" => "bbb"}))
        |> json_response(200)

      assert %{"paging" => %{"page_number" => 1, "page_size" => 50}} = response

      response2 =
        conn
        |> get(capitation_path(conn, :index, %{"page" => "aaa", "page_size" => "10bbb"}))
        |> json_response(200)

      assert %{"paging" => %{"page_number" => 1, "page_size" => 50}} = response2
    end

    test "reports ordered by billing date (latest go first)", %{conn: conn} do
      %{id: id1} =
        insert(
          :capitation_report,
          billing_date: Map.put(Date.utc_today(), :day, 1)
        )

      %{id: id2} =
        insert(
          :capitation_report,
          billing_date: Map.put(Date.utc_today(), :day, 2)
        )

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page_size" => "1"}))
        |> json_response(200)

      assert %{"data" => [%{"id" => response_id1}], "paging" => %{"page_number" => 1, "page_size" => 1}} = response
      assert response_id1 == id2

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page" => "2", "page_size" => "1"}))
        |> json_response(200)

      assert %{"data" => [%{"id" => response_id2}], "paging" => %{"page_number" => 2, "page_size" => 1}} = response
      assert response_id2 == id1
    end
  end

  describe "Capitation report details" do
    test "success get details", %{conn: conn} do
      capitation_reports_ids =
        Enum.reduce(1..4, [], fn _, acc ->
          id = Ecto.UUID.generate()

          for _ <- 1..5 do
            legal_entity_id = Ecto.UUID.generate()
            insert(:legal_entity, %{id: legal_entity_id, edrpou: "edrpou"})

            for _ <- 1..3 do
              contract_id = Ecto.UUID.generate()
              insert(:contracts, id: contract_id)

              for is_mountain <- [true, false] do
                for age_group <- ["0-18", "19-39", "40-60"] do
                  insert(
                    :capitation_report_detail,
                    capitation_report_id: id,
                    contract_id: contract_id,
                    legal_entity_id: legal_entity_id,
                    age_group: age_group,
                    mountain_group: is_mountain
                  )
                end
              end
            end
          end

          [id | acc]
        end)

      for id <- capitation_reports_ids do
        insert(:capitation_report, %{id: id})
      end

      response =
        conn
        |> get("/api/capitation_report_details", %{
          page_size: 3,
          edrpou: "edrpou",
          report_id: hd(capitation_reports_ids)
        })
        |> json_response(200)

      assert response["data"]

      Enum.each(response["data"], fn legal ->
        Enum.each(
          ["report_id", "legal_entity_name", "legal_entity_id", "edrpou", "billing_date", "capitation_contracts"],
          fn k ->
            assert Map.has_key?(legal, k)

            Enum.each(legal["capitation_contracts"], fn contract ->
              Enum.each(["contract_id", "contract_number", "details", "total"], fn k ->
                assert Map.has_key?(contract, k)
              end)

              Enum.each(contract["details"], fn detail ->
                Enum.each(["attributes", "mountain_group"], fn k -> assert Map.has_key?(detail, k) end)
              end)
            end)
          end
        )
      end)
    end
  end
end
