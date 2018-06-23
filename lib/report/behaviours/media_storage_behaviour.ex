defmodule Report.MediaStorageBehaviour do
  @moduledoc false

  @callback create_signed_url(
              action :: binary,
              bucket :: binary,
              resource_name :: binary,
              resource_id :: binary
            ) :: {:ok, result :: term} | {:error, reason :: term}

  @callback validate_signed_entity(rules :: list, settings :: list) :: {:ok, result :: term} | {:error, reason :: term}
end
