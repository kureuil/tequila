defmodule Tequila.Repo do
  use Ecto.Repo,
    otp_app: :tequila,
    adapter: Ecto.Adapters.Postgres
end
