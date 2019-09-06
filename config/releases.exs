import Config

scheme =
  case System.get_env("URL_SCHEME", "https") do
    "http" -> :http
    _ -> :https
  end

config :tequila, TequilaWeb.Endpoint,
  http: [port: System.get_env("PORT", "8378") |> Integer.parse() |> elem(0)],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  url: [host: {:system, "URL_HOST"}, port: {:system, "URL_PORT"}, scheme: scheme]

config :tequila, Tequila.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10,
  migration_primary_key: [name: :id, type: :binary_id]

config :tequila, :redis_url, System.get_env("REDIS_URL")
