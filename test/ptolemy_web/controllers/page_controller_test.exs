defmodule TequilaWeb.PageControllerTest do
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

    test "GET /", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, "/")
      assert redirected_to(conn) =~ Routes.channel_path(conn, :index)
    end
  end

  defp create_owner(_) do
    owner = fixture_owner()
    {:ok, owner: owner}
  end
end
