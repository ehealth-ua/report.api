defmodule Report.Web.ApiView do
  @moduledoc false

  use Report.Web, :view

  def render("declaration_count.json", %{parties: parties}) do
    Enum.map(parties, &Map.take(&1, ~w(id declaration_count)a))
  end
end
