defmodule TequilaWeb.PageControllerTest do
  use TequilaWeb.ConnCase

  alias Tequila.Fixtures

  describe "index" do
    setup [:create_owner]

    test "GET /", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, "/")
      assert redirected_to(conn) =~ Routes.channel_path(conn, :index)
    end
  end

  defp create_owner(_) do
    owner = Fixtures.user("louis@example.com")
    {:ok, owner: owner}
  end
end
