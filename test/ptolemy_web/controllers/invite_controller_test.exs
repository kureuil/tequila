defmodule TequilaWeb.InviteControllerTest do
  use TequilaWeb.ConnCase

  alias Tequila.Accounts

  def fixture_owner() do
    email = "louis@example.com"

    try do
      Accounts.get_user_by_email!(email)
    rescue
      _ in Ecto.NoResultsError ->
        {:ok, user} = Accounts.create_user(%{email: email})
        user
    end
  end

  describe "index" do
    setup [:create_owner]

    test "lists only invites created by the current user", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.invite_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("Pending invites")
    end
  end

  describe "redeem" do
    test "the redeem form pre-fills the email field" do
      # TODO
    end

    test "redeeming an invite deletes it" do
      # TODO
    end

    test "an invite older than 5 days can not be redeemed" do
      # TODO
    end

    test "the password filled in the form must match to redeem the invite" do
      # TODO
    end

    test "it is not possible to create an account with an already used email" do
      # TODO
    end
  end

  defp create_owner(_) do
    owner = fixture_owner()
    {:ok, owner: owner}
  end
end
