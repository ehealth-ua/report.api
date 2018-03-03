defmodule Report.Web.EmployeeController do
  @moduledoc false

  use Report.Web, :controller
  alias Report.Employees
  alias Scrivener.Page

  action_fallback(Report.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Employees.list(params) do
      render(conn, "index.json", paging: paging)
    end
  end
end
