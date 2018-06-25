defmodule Report.CapitationControllerTest do
  @moduledoc false

  use Report.Web.ConnCase

  describe "List capitation reports" do
    test "success", %{conn: conn} do
      %{id: id1} = insert(:capitation_report)
      %{id: id2} = insert(:capitation_report)

      response =
        conn
        |> get("/api/capitation_reports", %{page_size: 1})
        |> json_response(200)

      assert %{"data" => [%{"id" => response_id1}], "paging" => %{"page_number" => 1, "page_size" => 1}} = response
      assert response_id1 in [id1, id2]

      response =
        conn
        |> get("/api/capitation_reports", %{page_size: 1, page: 2})
        |> json_response(200)

      assert %{"data" => [%{"id" => response_id2}], "paging" => %{"page_number" => 2, "page_size" => 1}} = response
      assert response_id2 != response_id1
      assert response_id2 in [id1, id2]
    end
  end
end
