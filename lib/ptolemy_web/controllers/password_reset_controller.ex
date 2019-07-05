defmodule PtolemyWeb.PasswordResetController do
  use PtolemyWeb, :controller

  alias Ptolemy.Accounts

  def new(conn, _params) do
    conn
    |> put_layout("unauthenticated.html")
    |> render("new.html")
  end

  def send(conn, %{"email" => email}) do
    case Accounts.generate_password_reset_token(email) do
      {:ok, token} ->
        Accounts.get_user_by_email!(email)
        |> PtolemyWeb.AccountEmail.password_recovery(token)
        |> Ptolemy.Mailer.deliver()

        conn
        |> put_flash(
          :notice,
          gettext("An email has been sent to %{email}, please check your inbox.", email: email)
        )
        |> put_layout("unauthenticated.html")
        |> render("send.html", email: email)

      _ ->
        conn
        |> put_layout("unauthenticated.html")
        |> render("send.html", email: email)
    end
  end

  def reset(conn, %{"token" => token}) do
    case Accounts.get_user_by_recovery_token(token) do
      nil ->
        conn
        |> put_flash(
          :error,
          gettext(
            "It looks like you clicked on an invalid password reset link. Please try again."
          )
        )
        |> redirect(to: Routes.password_reset_path(conn, :new))

      user ->
        changeset = Accounts.change_password(%Accounts.PasswordReset{})

        conn
        |> put_layout("unauthenticated.html")
        |> render("reset.html", changeset: changeset, user: user, token: token)
    end
  end

  def apply(conn, %{"password_reset" => password_params, "token" => token}) do
    case Accounts.get_user_by_recovery_token(token) do
      nil ->
        conn
        |> put_flash(
          :error,
          gettext(
            "It looks like you clicked on an invalid password reset link. Please try again."
          )
        )
        |> redirect(to: Routes.password_reset_path(conn, :new))

      user ->
        case Accounts.update_password(user, password_params) do
          {:ok, _} ->
            conn
            |> put_flash(
              :info,
              gettext("Password updated successfully for %{user}", user: user.email)
            )
            |> redirect(to: Routes.session_path(conn, :new))

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_layout("unauthenticated.html")
            |> render("reset.html", changeset: changeset, user: user, token: token)

          {:error, _} ->
            conn
            |> put_flash(
              :error,
              "It looks like you clicked on an invalid password reset link. Please try again."
            )
            |> redirect(to: Routes.password_reset_path(conn, :new))
        end
    end
  end
end
