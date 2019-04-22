defmodule PtolemyWeb.ChannelControllerTest do
  use PtolemyWeb.ConnCase

  alias Ptolemy.Channels
  alias Ptolemy.Accounts

  @create_attrs %{name: "Programming", query: "#programming"}
  @update_attrs %{name: "Distributed systems", query: "#distributedsystems"}
  @invalid_attrs %{name: nil, query: nil}

  def fixture_channel() do
    owner = fixture_owner()
    {:ok, channel} = Channels.create_channel(@create_attrs, owner)
    channel
  end

  def fixture_home_channel() do
    attrs = %{name: "Home", query: "", default: true}
    owner = fixture_owner()
    {:ok, channel} = Channels.create_channel(attrs, owner)
    channel
  end

  def fixture_owner() do
    email = "louis@person.guru"

    try do
      Accounts.get_user_by_email!(email)
    rescue
      _ in Ecto.NoResultsError ->
        {:ok, user} = Accounts.create_user(%{email: email})
        user
    end
  end

  describe "index" do
    setup [:create_home_channel]

    test "redirects to home channel", %{conn: conn, home_channel: home_channel} do
      conn = get(conn, Routes.channel_path(conn, :index))
      assert redirected_to(conn) =~ "/channels/#{home_channel.id}"
    end
  end

  describe "new channel" do
    setup [:create_owner]

    test "renders form", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :new))
      assert html_response(conn, 200) =~ "Ajout d'un channel"
    end
  end

  describe "create channel" do
    setup [:create_owner]

    test "redirects to show when data is valid", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = post(conn, Routes.channel_path(conn, :create), channel: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.channel_path(conn, :show, id)

      conn = get(conn, Routes.channel_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = post(conn, Routes.channel_path(conn, :create), channel: @invalid_attrs)
      assert html_response(conn, 200) =~ "Ajout d'un channel"
    end
  end

  describe "edit channel" do
    setup [:create_channel, :create_owner]

    test "renders form for editing chosen channel", %{conn: conn, channel: channel, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.channel_path(conn, :edit, channel))
      assert html_response(conn, 200) =~ "Modification du channel \"#{channel.name}\""
    end
  end

  describe "update channel" do
    setup [:create_channel, :create_owner]

    test "redirects when data is valid", %{conn: conn, channel: channel, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = put(conn, Routes.channel_path(conn, :update, channel), channel: @update_attrs)
      assert redirected_to(conn) == Routes.channel_path(conn, :show, channel)

      conn = get(conn, Routes.channel_path(conn, :show, channel))
      assert html_response(conn, 200) =~ @update_attrs[:name]
    end

    test "renders errors when data is invalid", %{conn: conn, channel: channel, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = put(conn, Routes.channel_path(conn, :update, channel), channel: @invalid_attrs)
      assert html_response(conn, 200) =~ "Modification du channel \"#{channel.name}\""
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
        get(conn, Routes.channel_path(conn, :show, channel))
      end
    end
  end

  defp create_owner(_) do
    owner = fixture_owner()
    {:ok, owner: owner}
  end

  defp create_channel(_) do
    channel = fixture_channel()
    {:ok, channel: channel}
  end

  defp create_home_channel(_) do
    channel = fixture_home_channel()
    {:ok, home_channel: channel}
  end
end
