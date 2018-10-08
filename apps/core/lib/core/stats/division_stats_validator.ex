defmodule Core.Stats.DivisionStatsValidator do
  @moduledoc false

  import Ecto.Changeset

  alias Core.Stats.DivisionsRequest

  @fields_location ~w(
    north
    east
    south
    west
  )a

  def divisions_changeset(%DivisionsRequest{} = divisions_request, params) do
    divisions_request
    |> cast(params, DivisionsRequest.__schema__(:fields))
    |> validate_inclusion(:type, DivisionsRequest.types())
    |> validate_location_fields()
  end

  defp validate_location_fields(changeset) do
    case locations_field_passed?(changeset.changes) do
      true ->
        geo_format = [less_than_or_equal_to: 90, greater_than_or_equal_to: -90]

        changeset
        |> validate_required(@fields_location)
        |> validate_number(:north, geo_format)
        |> validate_number(:east, geo_format)
        |> validate_number(:south, geo_format)
        |> validate_number(:west, geo_format)

      false ->
        changeset
    end
  end

  defp locations_field_passed?(changes) do
    Enum.reduce_while(changes, false, fn {k, _}, _acc ->
      if k in @fields_location, do: {:halt, true}, else: {:cont, false}
    end)
  end
end
