defimpl Ecto.LoggerJSON.StructParser, for: Geo.Point do
  def parse(value), do: Geo.JSON.encode(value)
end
