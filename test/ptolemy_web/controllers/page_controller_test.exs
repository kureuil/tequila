defmodule PtolemyWeb.PageControllerTest do
  use PtolemyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn) =~ Routes.channel_path(conn, :index)
  end
end
