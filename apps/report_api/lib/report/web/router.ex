defmodule Report.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """

  use Report.Web, :router
  require Logger

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_secure_browser_headers)
  end

  scope "/", Report.Web do
    pipe_through(:api)

    scope "/api" do
      get("/capitation_reports", CapitationController, :index)
      get("/capitation_report_details", CapitationController, :details)
    end

    scope "/reports" do
      scope "/stats" do
        get("/", StatsController, :index)
        get("/divisions", StatsController, :divisions)
        get("/division/:id", StatsController, :division)
        get("/regions", StatsController, :regions)
        get("/histogram", StatsController, :histogram)
      end
    end

    scope "/stats/employees" do
      get("/", EmployeeController, :index)
      get("/:id", EmployeeController, :show)
    end

    get("/reimbursement_report", ReimbursementController, :index)
    get("/reimbursement_report_download", ReimbursementController, :download)

    scope "/api" do
      post("/parties/declaration_count", ApiController, :declaration_count)
    end
  end
end
