defmodule Ptolemy.Repo do
  use Ecto.Repo,
    otp_app: :ptolemy,
    adapter: Ecto.Adapters.Postgres
end
