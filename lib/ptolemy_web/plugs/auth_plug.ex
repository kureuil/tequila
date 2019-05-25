defmodule PtolemyWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  alias PtolemyWeb.Router.Helpers, as: Routes
  alias Ptolemy.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil ->
        case get_session(conn, "user:session") do
          session_id ->
            try do
              session = Accounts.get_valid_session!(session_id)
              now = NaiveDateTime.utc_now()
              validity_threshold = session.updated_at |> NaiveDateTime.add(60 * 60 * 24 * 3)

              case NaiveDateTime.compare(validity_threshold, now) do
                :gt ->
                  try do
                    current_user = Accounts.get_user!(session.user_id)
                    Accounts.touch_session!(session_id)
                    assign(conn, :current_user, current_user)
                  rescue
                    _ -> clear_session_and_redirect(conn)
                  end

                _ ->
                  Accounts.invalidate_session!(session_id)
                  clear_session_and_redirect(conn)
              end
            rescue
              error ->
                clear_session_and_redirect(conn)
            end

          nil ->
            clear_session_and_redirect(conn)
        end

      _ ->
        conn
    end
  end

  defp clear_session_and_redirect(conn) do
    conn
    |> clear_session()
    |> configure_session(renew: true)
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end
