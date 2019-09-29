defmodule TequilaWeb.InviteControllerTest do
  use TequilaWeb.ConnCase

  alias Phoenix.HTML

  alias Tequila.Fixtures
  alias Tequila.Invites

  @owner "louis@example.com"

  describe "index" do
    setup [:create_owner]

    test "lists only invites created by the current user", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.invite_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("Pending invites")
    end
  end

  describe "redeem" do
    setup [:create_owner, :create_invite, :create_old_invite]

    test "the redeem form pre-fills the email field", %{conn: conn, invite: invite} do
      conn = get(conn, Routes.invite_path(conn, :redeem, invite.id))
      assert html_response(conn, 200) =~ invite.invitee
    end

    test "redeeming an invite deletes it", %{conn: conn, invite: invite} do
      path = Routes.invite_path(conn, :register, invite.id)

      redeem_params = %{
        email: invite.invitee,
        password: "supersecretpassword",
        password_confirmation: "supersecretpassword"
      }

      conn = post(conn, path, redeem: redeem_params)
      assert redirected_to(conn) =~ Routes.session_path(conn, :new)

      assert_raise Ecto.NoResultsError, fn ->
        Invites.find!(invite.id)
      end
    end

    test "an invite older than 5 days can not be redeemed", %{conn: conn, old_invite: invite} do
      path = Routes.invite_path(conn, :register, invite.id)

      redeem_params = %{
        email: invite.invitee,
        password: "supersecretpassword",
        password_confirmation: "supersecretpassword"
      }

      conn = post(conn, path, redeem: redeem_params)
      assert redirected_to(conn) =~ Routes.session_path(conn, :new)

      assert get_flash(conn, :error) ==
               gettext(
                 "The invite link you used isn't valid. Please ask the person that invited you again."
               )
    end

    test "the password filled in the form must match to redeem the invite", %{
      conn: conn,
      invite: invite
    } do
      path = Routes.invite_path(conn, :register, invite.id)

      redeem_params = %{
        email: invite.invitee,
        password: "supersecretpassword",
        password_confirmation: "uspersecretpassword"
      }

      conn = post(conn, path, redeem: redeem_params)

      assert html_response(conn, 200) =~
               gettext("Redeem invite") |> HTML.html_escape() |> HTML.safe_to_string()

      assert Invites.find!(invite.id) != nil
    end

    test "it is not possible to create an account with an already used email", %{
      conn: conn,
      invite: invite,
      owner: owner
    } do
      path = Routes.invite_path(conn, :register, invite.id)

      redeem_params = %{
        email: owner.email,
        password: "supersecretpassword",
        password_confirmation: "supersecretpassword"
      }

      conn = post(conn, path, redeem: redeem_params)

      assert html_response(conn, 200) =~
               gettext("Redeem invite") |> HTML.html_escape() |> HTML.safe_to_string()

      assert Invites.find!(invite.id) != nil
    end
  end

  defp create_owner(_) do
    owner = Fixtures.user(@owner)
    {:ok, owner: owner}
  end

  defp create_invite(_) do
    owner = Fixtures.user(@owner)

    inserted_at =
      DateTime.utc_now()
      |> DateTime.add(-3 * 60 * 60 * 24, :second)

    invite = Fixtures.invite(owner, inserted_at)
    {:ok, invite: invite}
  end

  defp create_old_invite(_) do
    owner = Fixtures.user(@owner)

    inserted_at =
      DateTime.utc_now()
      |> DateTime.add(-6 * 60 * 60 * 24, :second)

    invite = Fixtures.invite(owner, inserted_at)
    {:ok, old_invite: invite}
  end
end
