# Enable PostGIS for Ecto
Postgrex.Types.define(
  Core.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison
)
