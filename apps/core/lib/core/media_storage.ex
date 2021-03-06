defmodule Core.MediaStorage do
  @moduledoc """
  Media Storage on Google Cloud Platform
  """
  @media_storage_timeout_error "MediaStorage is unavaible and max retries exceeded"
  @behaviour Core.MediaStorageBehaviour

  use HTTPoison.Base
  use Confex, otp_app: :core

  alias Core.ResponseDecoder

  require Logger

  def options, do: config()[:hackney_options]

  def create_signed_url(action, bucket, resource_name, resource_id) do
    data = %{
      "secret" => %{
        "action" => action,
        "bucket" => bucket,
        "resource_id" => resource_id,
        "resource_name" => resource_name
      }
    }

    create_signed_url(data)
  end

  def create_signed_url(data) do
    config()[:endpoint]
    |> Kernel.<>("/media_content_storage_secrets")
    |> post!(Jason.encode!(data), [{"Content-Type", "application/json"}], options())
    |> ResponseDecoder.check_response()
  end

  def validate_signed_entity(_, retry: 0, timeout: _), do: :error

  def validate_signed_entity(rules, retry: retry, timeout: timeout) do
    response =
      config()[:endpoint]
      |> Kernel.<>("/validate_signed_entity")
      |> post(Jason.encode!(rules), [{"Content-Type", "application/json"}], options())

    case check_gcs_response(response) do
      {:ok, body} -> {:ok, Jason.decode!(body)}
      _ -> validate_signed_entity(rules, retry: retry - 1, timeout: timeout + 1000)
    end
  end

  def store_signed_content(signed_content, bucket, id, headers) do
    store_signed_content(config()[:enabled?], bucket, signed_content, id, headers)
  end

  def store_signed_content(true, bucket, signed_content, id, _headers) do
    "PUT"
    |> create_signed_url(config()[bucket], "capitation.csv", id)
    |> put_signed_content(signed_content, retry: 5, timeout: 60_000)
  end

  def store_signed_content(false, _bucket, _signed_content, _id, _headers) do
    {:ok, "Media Storage is disabled in config"}
  end

  def put_signed_content(_, _, retry: 0, timeout: _), do: {:error, @media_storage_timeout_error}

  def put_signed_content({:ok, %{"data" => data}}, signed_content, retry: retry, timeout: timeout) do
    headers = [{"Content-Type", ""}]
    secret_url = Map.fetch!(data, "secret_url")

    case check_gcs_response(put(secret_url, signed_content, headers, options())) do
      {:ok, _} ->
        {:ok, signed_to_public_url(secret_url)}

      _ ->
        :timer.sleep(timeout)
        put_signed_content({:ok, %{"data" => data}}, signed_content, retry: retry - 1, timeout: timeout + timeout)
    end
  end

  def put_signed_content(err, _signed_content) do
    Logger.error(fn -> "Cannot create signed url. Response: #{inspect(err)}" end)
    err
  end

  def check_gcs_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code in [200, 201] do
    {:ok, body}
  end

  def check_gcs_response({:ok, %HTTPoison.Response{body: body}}) do
    {:error, body}
  end

  def check_gcs_response({:error, %HTTPoison.Error{}}) do
    :error
  end

  defp signed_to_public_url(url) do
    url
    |> URI.parse()
    |> Map.put(:query, nil)
    |> URI.to_string()
  end
end
