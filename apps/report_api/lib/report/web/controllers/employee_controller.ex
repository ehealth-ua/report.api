defmodule Report.Web.EmployeeController do
  @moduledoc false

  use Report.Web, :controller
  alias Core.Employees
  alias Core.Replica.Employee
  alias Scrivener.Page

  action_fallback(Report.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Employees.list(params) do
      render(conn, "index.json", paging: paging)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Employee{} = employee <- Employees.get_by_id(id) do
      render(conn, "show.json", employee: employee)
    end
  end
end
