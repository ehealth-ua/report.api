defmodule Report.CapitationControllerTest do
  @moduledoc false

  use Report.Web.ConnCase
  alias Core.CapitationReportDetail
  alias Core.Replica.LegalEntity
  alias Core.Repo
  import Ecto.Query

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
    test "get details not found", %{conn: conn} do
      cr = insert(:capitation_report)

      response =
        conn
        |> get("/api/capitation_report_details", %{
          page_size: 2,
          report_id: cr.id
        })
        |> json_response(200)

      assert response["data"] == []
    end

    test "get details success", %{conn: conn} do
      for _ <- 1..2 do
        cr = insert(:capitation_report)

        for _ <- 1..3 do
          legal_entity = insert(:legal_entity)

          for _ <- 1..2 do
            contract = insert(:contracts)

            for is_mountain <- [true, false] do
              for age_group <- ["0-18", "19-39", "40-60"] do
                insert(
                  :capitation_report_detail,
                  capitation_report_id: cr.id,
                  contract_id: contract.id,
                  legal_entity_id: legal_entity.id,
                  age_group: age_group,
                  mountain_group: is_mountain,
                  declaration_count: 100
                )
              end
            end
          end
        end
      end

      cd = CapitationReportDetail |> limit(^1) |> Repo.one()

      le =
        LegalEntity
        |> join(:inner, [l], c in CapitationReportDetail, c.legal_entity_id == l.id and c.id == ^cd.id)
        |> limit(^1)
        |> Repo.one()

      response =
        conn
        |> get("/api/capitation_report_details", %{
          page_size: 2,
          edrpou: le.edrpou,
          legal_entity_id: le.id,
          report_id: cd.capitation_report_id
        })
        |> json_response(200)

      assert response["data"]
      assert length(response["data"]) == 1

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
