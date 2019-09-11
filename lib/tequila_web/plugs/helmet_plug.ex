defmodule TequilaWeb.HelmetPlug do
  import Plug.Conn

  def init(_opts) do
    opts = []
    opts = case Mix.env do
      :prod -> Keyword.put(opts, :csp, "default-src 'self'")
      _ -> Keyword.put(opts, :csp, "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'")
    end
    opts
  end

  def call(conn, opts) do
    csp = Keyword.get(opts, :csp, "default-src 'self'")
    conn
    |> put_resp_header("referrer-policy", "strict-origin")
    |> put_resp_header("content-security-policy", csp)
  end
end
