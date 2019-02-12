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

      assert %{
               "data" => [%{"id" => response_id1}],
               "paging" => %{"page_number" => 1, "page_size" => 1}
             } = response

      assert response_id1 in [id1, id2]

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page" => "2", "page_size" => "1"}))
        |> json_response(200)

      assert %{
               "data" => [%{"id" => response_id2}],
               "paging" => %{"page_number" => 2, "page_size" => 1}
             } = response

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

      assert %{
               "data" => [%{"id" => response_id1}],
               "paging" => %{"page_number" => 1, "page_size" => 1}
             } = response

      assert response_id1 == id2

      response =
        conn
        |> get(capitation_path(conn, :index, %{"page" => "2", "page_size" => "1"}))
        |> json_response(200)

      assert %{
               "data" => [%{"id" => response_id2}],
               "paging" => %{"page_number" => 2, "page_size" => 1}
             } = response

      assert response_id2 == id1
    end
  end

  describe "Capitation report details" do
    test "invalid legal_entity_id", %{conn: conn} do
      resp =
        conn
        |> get("/api/capitation_report_details", %{
          legal_entity_id: "not UUID"
        })
        |> json_response(422)

      assert [%{"entry" => "$.legal_entity_id"}] = resp["error"]["invalid"]
    end

    test "invalid report_id", %{conn: conn} do
      resp =
        conn
        |> get("/api/capitation_report_details", %{
          report_id: "not UUID"
        })
        |> json_response(422)

      assert [%{"entry" => "$.report_id", "entry_type" => "json_data_property"}] = resp["error"]["invalid"]
    end

    test "invalid UUID-like report_id", %{conn: conn} do
      resp =
        conn
        |> get("/api/capitation_report_details", %{
          report_id: "3160405192-08e07522-ba03-4a8f-a07e-c752e09ca84f"
        })
        |> json_response(422)

      assert [%{"entry" => "$.report_id", "entry_type" => "json_data_property"}] = resp["error"]["invalid"]
    end

    test "invalid edrpou", %{conn: conn} do
      resp =
        conn
        |> get("/api/capitation_report_details", %{
          edrpou: "0123"
        })
        |> json_response(422)

      assert [%{"entry" => "$.edrpou"}] = resp["error"]["invalid"]
    end

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
        |> join(
          :inner,
          [l],
          c in CapitationReportDetail,
          c.legal_entity_id == l.id and c.id == ^cd.id
        )
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
          [
            "report_id",
            "legal_entity_name",
            "legal_entity_id",
            "edrpou",
            "billing_date",
            "capitation_contracts"
          ],
          fn k ->
            assert Map.has_key?(legal, k)

            Enum.each(legal["capitation_contracts"], fn contract ->
              Enum.each(["contract_id", "contract_number", "details", "total"], fn k ->
                assert Map.has_key?(contract, k)
              end)

              assert MapSet.new([%{"0-18" => 200}, %{"19-39" => 200}, %{"40-60" => 200}]) ==
                       MapSet.new(contract["total"])

              Enum.each(contract["details"], fn detail ->
                Enum.each(["attributes", "mountain_group"], fn k ->
                  assert Map.has_key?(detail, k)
                end)
              end)
            end)
          end
        )
      end)
    end

    test "get details success from relaited legal entities", %{conn: conn} do
      cr = insert(:capitation_report)
      legal_entity = insert(:legal_entity, edrpou: "0123456789")
      child_legal_entity1 = insert(:legal_entity, edrpou: "9876543210")
      child_legal_entity2 = insert(:legal_entity, edrpou: "8899771122")

      insert(
        :related_legal_entity,
        merged_to_id: legal_entity.id,
        merged_from_id: child_legal_entity1.id
      )

      insert(
        :related_legal_entity,
        merged_to_id: legal_entity.id,
        merged_from_id: child_legal_entity2.id
      )

      Enum.each([child_legal_entity1, child_legal_entity2, legal_entity], fn le ->
        contract = insert(:contracts)

        insert(
          :capitation_report_detail,
          capitation_report_id: cr.id,
          contract_id: contract.id,
          legal_entity_id: le.id,
          age_group: "0-18",
          declaration_count: 100
        )
      end)

      response =
        conn
        |> get("/api/capitation_report_details", %{
          page_size: 3,
          legal_entity_id: legal_entity.id
        })
        |> json_response(200)

      assert %{
               "page_number" => 1,
               "page_size" => 3,
               "total_entries" => 3,
               "total_pages" => 1
             } == response["paging"]

      reports = response["data"]

      assert reports
      assert length(reports) == 3

      assert ["0123456789", "8899771122", "9876543210"] ==
               reports
               |> Enum.reduce([], fn %{"edrpou" => edrpou}, acc -> [edrpou | acc] end)
               |> MapSet.new()
               |> MapSet.to_list()
    end

    test "get details success only from legal entity if no merged", %{conn: conn} do
      cr = insert(:capitation_report)
      contract = insert(:contracts)
      legal_entity = insert(:legal_entity, edrpou: "0123456789")
      another_legal_entity = insert(:legal_entity, edrpou: "9876543210")

      Enum.each([another_legal_entity, legal_entity], fn le ->
        insert(
          :capitation_report_detail,
          capitation_report_id: cr.id,
          contract_id: contract.id,
          legal_entity_id: le.id,
          age_group: "0-18",
          declaration_count: 100
        )
      end)

      response =
        conn
        |> get("/api/capitation_report_details", %{
          page_size: 2,
          legal_entity_id: legal_entity.id
        })
        |> json_response(200)

      reports = response["data"]
      assert [%{"edrpou" => "0123456789"}] = reports
    end
  end
end
