defmodule TequilaWeb.AuthPlugTest do
  use TequilaWeb.ConnCase
  alias Tequila.Repo
  alias Tequila.Accounts
  alias Tequila.Fixtures
  alias TequilaWeb.AuthPlug

  @email "louis@example.com"

  describe "Authentication Plug" do
    setup [:create_owner, :create_credential]

    test "Redirects to sign in page if there is no data in session", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, %{})
      conn = AuthPlug.call(conn, %{})
      assert redirected_to(conn) =~ Routes.session_path(conn, :new)
    end

    test "Ignores session data if :current_user is already assigned", %{
      conn: conn,
      owner: owner,
      credential: credential
    } do
      {:ok, other_user} =
        Accounts.create_user(%{
          email: Faker.Internet.email()
        })

      session =
        Repo.insert!(%Accounts.Session{
          invalidated_at: nil,
          user_id: owner.id,
          credential_id: credential.id
        })

      conn = Plug.Test.init_test_session(conn, %{"user:session" => session.id})
      conn = Plug.Conn.assign(conn, :current_user, other_user)
      conn = AuthPlug.call(conn, %{})
      assert conn.assigns[:current_user] == other_user
    end

    test "Assigns to the connection the user associated to the session", %{
      conn: conn,
      owner: owner,
      credential: credential
    } do
      session =
        Repo.insert!(%Accounts.Session{
          invalidated_at: nil,
          user_id: owner.id,
          credential_id: credential.id
        })

      conn = Plug.Test.init_test_session(conn, %{"user:session" => session.id})
      conn = AuthPlug.call(conn, %{})
      assert conn.assigns[:current_user].id == owner.id
    end
  end

  defp create_owner(_) do
    owner = Fixtures.user(@email)
    {:ok, owner: owner}
  end

  defp create_credential(_) do
    {:ok, owner: user} = create_owner(nil)
    credential = Fixtures.credential("email", @email, user)
    {:ok, credential: credential}
  end
end
