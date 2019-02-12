defmodule Report.Web.FallbackController do
  @moduledoc """
  This controller should be used as `action_fallback` in rest of controllers to remove duplicated error handling.
  """
  use Report.Web, :controller
  alias EView.Views.{Error, ValidationError}

  def call(conn, {:error, json_schema_errors}) when is_list(json_schema_errors) do
    conn
    |> put_status(422)
    |> put_view(ValidationError)
    |> render("422.json", %{schema: json_schema_errors})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(Error)
    |> render(:"403")
  end

  def call(conn, {:error, :access_denied}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(Error)
    |> render(:"401")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(Error)
    |> render(:"404")
  end

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> put_view(Error)
    |> render(:"404")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ValidationError)
    |> render(:"422", changeset)
  end

  def call(conn, %Ecto.Changeset{} = changeset) do
    call(conn, {:error, changeset})
  end

  def call(conn, {:error, {:conflict, reason}}) do
    call(conn, {:conflict, reason})
  end

  def call(conn, {:conflict, reason}) do
    conn
    |> put_status(:conflict)
    |> put_view(Error)
    |> render(:"409", reason)
  end
end
