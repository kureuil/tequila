import Config

config :tequila, TequilaWeb.Endpoint, server: true

config :tequila, TequilaWeb.Endpoint,
  http: [port: 8000],
  url: [host: "example.com", port: 80]

config :tequila, Tequila.Repo,
  url: "postgres://tequila:imnotmeantforproduction@postgres:5432/tequila_dev",
  pool_size: 10,
  migration_primary_key: [name: :id, type: :binary_id]

config :tequila, :redis_url, "redis://redisearch:6379/0"
