defmodule Report.Web.ErrorViewTest do
  use Report.Web.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(Report.Web.ErrorView, "404.json", []) == %{errors: %{detail: "Page not found"}}
  end

  test "render 500.json" do
    assert render(Report.Web.ErrorView, "500.json", []) == %{errors: %{detail: "Internal server error"}}
  end

  @tag :pending
  test "render any other" do
    assert render(Report.Web.ErrorView, "500.json", []) == %{errors: %{detail: "Internal server error"}}
  end
end