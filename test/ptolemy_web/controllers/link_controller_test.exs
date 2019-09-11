defmodule TequilaWeb.LinkControllerTest do
  use TequilaWeb.ConnCase

  alias Tequila.Index
  alias Tequila.Accounts

  @create_attrs %{
    location: "https://github.com/",
    title: "Tequila repository",
    tags: "knowledgebase, learning, collaborative, sharing"
  }
  @update_attrs %{
    location: "https://kureuil.github.io/tequila/",
    title: "Tequila homepage",
    tags: "knowledgebase, learning, collaborative, sharing"
  }
  @invalid_attrs %{location: nil, title: nil}

  def fixture(:link) do
    owner = fixture(:owner)
    {:ok, link} = Index.create_submit(@create_attrs, owner)
    link
  end

  def fixture(:owner) do
    email = "louis@example.com"

    try do
      Accounts.get_user_by_email!(email)
    rescue
      _ in Ecto.NoResultsError ->
        {:ok, user} = Accounts.create_user(%{email: email})
        user
    end
  end

  describe "new link" do
    setup [:create_owner]

    test "renders form", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.link_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("New link")
    end
  end

  describe "create link" do
    setup [:create_owner]

    test "redirects to show when data is valid", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = post(conn, Routes.link_path(conn, :create), submit: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.link_path(conn, :show, id)

      conn = recycle(conn)
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.link_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs[:title]
    end

    test "renders errors when data is invalid", %{conn: conn, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = post(conn, Routes.link_path(conn, :create), submit: @invalid_attrs)
      assert html_response(conn, 200) =~ gettext("New link")
    end
  end

  describe "edit link" do
    setup [:create_link, :create_owner]

    test "renders form for editing chosen link", %{conn: conn, link: link, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.link_path(conn, :edit, link))
      assert html_response(conn, 200) =~ gettext("Editing link %{link}", link: link.title)
    end
  end

  describe "update link" do
    setup [:create_link, :create_owner]

    test "redirects when data is valid", %{conn: conn, link: link, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = put(conn, Routes.link_path(conn, :update, link), submit: @update_attrs)
      assert redirected_to(conn) == Routes.link_path(conn, :show, link)

      conn = recycle(conn)
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = get(conn, Routes.link_path(conn, :show, link))
      assert html_response(conn, 200) =~ @update_attrs[:title]
    end

    test "renders errors when data is invalid", %{conn: conn, link: link, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = put(conn, Routes.link_path(conn, :update, link), submit: @invalid_attrs)
      assert html_response(conn, 200) =~ gettext("Editing link %{link}", link: link.title)
    end
  end

  describe "delete link" do
    setup [:create_link, :create_owner]

    test "deletes chosen link", %{conn: conn, link: link, owner: owner} do
      conn = Plug.Conn.assign(conn, :current_user, owner)
      conn = delete(conn, Routes.link_path(conn, :delete, link))
      assert redirected_to(conn) == Routes.channel_path(conn, :index)

      assert_error_sent 404, fn ->
        conn = recycle(conn)
        conn = Plug.Conn.assign(conn, :current_user, owner)
        get(conn, Routes.link_path(conn, :show, link))
      end
    end
  end

  defp create_link(_) do
    link = fixture(:link)
    {:ok, link: link}
  end

  defp create_owner(_) do
    owner = fixture(:owner)
    {:ok, owner: owner}
  end
end
