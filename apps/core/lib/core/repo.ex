defmodule Core.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :core, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10, max_page_size: 500, options: [allow_out_of_range_pages: true]
end
