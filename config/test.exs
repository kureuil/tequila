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
  username: "ptolemy",
  password: "imnotmeantforproduction",
  database: "ptolemy_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [name: :id, type: :binary_id]
