defmodule TequilaWeb.ChannelControllerTest do
  use TequilaWeb.ConnCase

  alias Tequila.Channels
  alias Tequila.Fixtures

  @create_attrs %{name: "Programming", query: "#programming"}
  @update_attrs %{name: "Distributed systems", query: "#distributedsystems"}
  @invalid_attrs %{name: nil, query: nil}

  @owner "louis@example.com"
  @guest "walouis@example.com"

  describe "index" do
    setup [:create_owner, :create_home_channel]

    test "redirects to home channel", %{conn: conn, owner: owner, home_channel: home_channel} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :index))
      assert redirected_to(conn) =~ "/channels/#{home_channel.id}"
    end
  end

  describe "new channel" do
    setup [:create_owner]

    test "renders form", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("New channel")
    end
  end

  describe "create channel" do
    setup [:create_owner]

    test "redirects to show when data is valid", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = post(conn, Routes.channel_path(conn, :create), channel: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.channel_path(conn, :show, id)

      conn = recycle(conn)
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = post(conn, Routes.channel_path(conn, :create), channel: @invalid_attrs)
      assert html_response(conn, 200) =~ gettext("New channel")
    end
  end

  describe "show channel" do
    setup [:create_owner, :create_forbidden_channel]

    test "redirects to index when viewing channel of other user", %{
      conn: conn,
      owner: owner,
      forbidden_channel: forbidden_channel
    } do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :show, forbidden_channel))
      assert get_flash(conn, :error) != ""
    end
  end

  describe "edit channel" do
    setup [:create_channel, :create_owner]

    test "renders form for editing chosen channel", %{conn: conn, channel: channel, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :edit, channel))

      assert html_response(conn, 200) =~
               gettext("Editing channel %{channel}", channel: channel.name)
    end
  end

  describe "update channel" do
    setup [:create_channel, :create_owner]

    test "redirects when data is valid", %{conn: conn, channel: channel, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = put(conn, Routes.channel_path(conn, :update, channel), channel: @update_attrs)
      assert redirected_to(conn) == Routes.channel_path(conn, :show, channel)

      conn = recycle(conn)
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :show, channel))
      assert html_response(conn, 200) =~ @update_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn, channel: channel, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = put(conn, Routes.channel_path(conn, :update, channel), channel: @invalid_attrs)

      assert html_response(conn, 200) =~
               gettext("Editing channel %{channel}", channel: channel.name)
    end
  end

  describe "delete channel" do
    setup [:create_channel, :create_home_channel, :create_owner]

    test "deletes chosen channel", %{
      conn: conn,
      channel: channel,
      home_channel: home_channel,
      owner: owner
    } do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = delete(conn, Routes.channel_path(conn, :delete, channel))
      assert redirected_to(conn) == Routes.channel_path(conn, :show, home_channel)

      assert_error_sent 404, fn ->
        conn = recycle(conn)
        conn = Plug.Conn.assign(conn, :current_user, owner)
        get(conn, Routes.channel_path(conn, :show, channel))
      end
    end
  end

  defp create_owner(_) do
    owner = Fixtures.user(@owner)
    {:ok, owner: owner}
  end

  defp create_guest(_) do
    guest = Fixtures.user(@guest)
    {:ok, guest: guest}
  end

  defp create_channel(_) do
    attrs = %{name: "Programming", query: "#programming"}
    {:ok, owner: owner} = create_owner(nil)
    {:ok, channel} = Channels.create_channel(attrs, owner)
    {:ok, channel: channel}
  end

  defp create_home_channel(_) do
    attrs = %{name: "Home", query: "", default: true}
    {:ok, owner: owner} = create_owner(nil)
    {:ok, channel} = Channels.create_channel(attrs, owner)
    {:ok, home_channel: channel}
  end

  defp create_forbidden_channel(_) do
    attrs = %{name: "Video games", query: "#videogames"}
    {:ok, guest: owner} = create_guest(nil)
    {:ok, channel} = Channels.create_channel(attrs, owner)
    {:ok, forbidden_channel: channel}
  end
end
