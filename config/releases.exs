import Config

config :tequila, TequilaWeb.Endpoint,
  http: [port: System.get_env("PORT", "8378") |> Integer.parse() |> elem(0)],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  url: [
    host: {:system, "URL_HOST"},
    port: {:system, "URL_PORT"},
    scheme: System.get_env("URL_SCHEME", "https")
  ]

config :tequila, Tequila.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10,
  migration_primary_key: [name: :id, type: :binary_id]

config :tequila, :redis_url, System.get_env("REDIS_URL")

config :tequila, :public_email, System.get_env("PUBLIC_EMAIL", "tequila@localhost")

config :tequila, Tequila.Mailer,
  adapter: Swoosh.Adapters.Postmark,
  api_key: System.get_env("POSTMARK_API_KEY")
