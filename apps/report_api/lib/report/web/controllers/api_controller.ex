defmodule Report.Web.ApiController do
  @moduledoc false

  use Report.Web, :controller
  alias Core.Parties

  action_fallback(Report.Web.FallbackController)

  def declaration_count(conn, params) do
    with {:ok, parties} <- Parties.list(params) do
      render(conn, "declaration_count.json", parties: parties)
    end
  end
end
