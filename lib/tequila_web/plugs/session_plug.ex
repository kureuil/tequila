defmodule TequilaWeb.SessionPlug do
  def init(_opts) do
    # The session will be stored in the cookie and signed,
    # this means its contents can be read but not tampered with.
    # Set :encryption_salt if you would also like to encrypt it.
    Plug.Session.init(
      store: :cookie,
      key: "_tequila_key",
      signing_salt: "JPY8ZFCC",
      extra: "SameSite=Lax"
    )
  end

  def call(conn, opts) do
    scheme = TequilaWeb.Endpoint.struct_url().scheme

    key =
      case scheme do
        "https" ->
          "__Host-tequila_key"

        _ ->
          "_tequila_key"
      end

    opts =
      opts
      |> Map.put(:key, key)
      |> Map.put(:cookie_opts, Keyword.put(opts[:cookie_opts], :secure, scheme == "https"))

    Plug.Session.call(conn, opts)
  end
end
