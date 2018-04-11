defmodule Report.Web.ApiControllerTest do
  @moduledoc false

  use Report.Web.ConnCase

  describe "declaration_count" do
    test "empty employee ids", %{conn: conn} do
      conn = post(conn, api_path(conn, :declaration_count))
      assert resp = json_response(conn, 422)

      assert %{
               "invalid" => [
                 %{
                   "entry" => "$.ids",
                   "entry_type" => "json_data_property",
                   "rules" => [
                     %{
                       "description" => "can't be blank",
                       "params" => [],
                       "rule" => "required"
                     }
                   ]
                 }
               ]
             } = resp["error"]
    end

    test "invalid employee ids", %{conn: conn} do
      conn = post(conn, api_path(conn, :declaration_count), %{"ids" => ["invalid"]})
      assert resp = json_response(conn, 422)

      assert %{
               "invalid" => [
                 %{
                   "entry" => "$.ids",
                   "entry_type" => "json_data_property",
                   "rules" => [
                     %{
                       "description" => "is invalid",
                       "params" => ["uuid"],
                       "rule" => "cast"
                     }
                   ]
                 }
               ]
             } = resp["error"]
    end

    test "success declaration_count by party ids", %{conn: conn} do
      %{id: id, declaration_count: declaration_count} = insert(:party, declaration_count: 10)
      insert(:party)
      conn = post(conn, api_path(conn, :declaration_count), %{"ids" => [id]})
      assert resp = json_response(conn, 200)
      assert [%{"declaration_count" => ^declaration_count, "id" => ^id}] = resp["data"]
    end
  end
end
