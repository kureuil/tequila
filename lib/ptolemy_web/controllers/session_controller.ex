defmodule PtolemyWeb.SessionController do
  use PtolemyWeb, :controller

  alias Ptolemy.Accounts

  def new(conn, _params) do
    conn
    |> put_layout("unauthenticated.html")
    |> render("new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_by_email_and_pass(email, password) do
      {:ok, session} ->
        conn
        |> configure_session(renew: true)
        |> put_flash(:info, gettext("Welcome back !"))
        |> put_session("user:session", session.id)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Invalid email/password combination"))
        |> put_layout("unauthenticated.html")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    Accounts.invalidate_session!(get_session(conn, "user:session"))

    conn
    |> clear_session()
    |> configure_session(renew: true)
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
