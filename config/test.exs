use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ptolemy, PtolemyWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ptolemy, Ptolemy.Repo,
  username: System.get_env("TEST_DATABASE_USER") || "ptolemy",
  password: System.get_env("TEST_DATABASE_PASS") || "imnotmeantforproduction",
  database: System.get_env("TEST_DATABASE_NAME") || "ptolemy_test",
  hostname: System.get_env("TEST_DATABASE_HOST") || "localhost",
  port: (System.get_env("TEST_DATABASE_PORT") || "5432") |> Integer.parse() |> elem(0),
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [name: :id, type: :binary_id]
