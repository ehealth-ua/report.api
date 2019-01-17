defmodule Report.Validators.JsonSchema do
  @moduledoc """
  Validates JSON schema
  """

  use JValid

  use_schema(:capitation_report_details, "specs/schemas/capitation_report_details.json")
  load_schema("specs/schemas/capitation_report_details.json")

  def validate(schema, params),
    do:
      @schemas
      |> Keyword.get(schema)
      |> validate_schema(params)
end
