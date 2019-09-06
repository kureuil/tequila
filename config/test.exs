use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tequila, TequilaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :tequila, Tequila.Repo,
  username: System.get_env("TEST_DATABASE_USER") || "tequila",
  password: System.get_env("TEST_DATABASE_PASS") || "imnotmeantforproduction",
  database: System.get_env("TEST_DATABASE_NAME") || "tequila_test",
  hostname: System.get_env("TEST_DATABASE_HOST") || "localhost",
  port: System.get_env("TEST_DATABASE_PORT", "5432") |> Integer.parse() |> elem(0),
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [name: :id, type: :binary_id]

config :pbkdf2_elixir, :rounds, 1

config :tequila, Tequila.Mailer, adapter: Swoosh.Adapters.Local

config :tequila, :redis_url, System.get_env("TEST_REDIS_URL") || "redis://localhost:6379/1"
