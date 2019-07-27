defmodule PtolemyWeb.InviteController do
  use PtolemyWeb, :controller

  alias Ptolemy.Invites
  alias Ptolemy.Invites.Invite

  def index(conn, _params) do
    invites = Invites.list_by_owner(conn.assigns[:current_user])
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invite" => invite}) do
    redirect(conn, to: Routes.invite_path(conn, :index))
  end

  def delete(conn, _params) do
    redirect(conn, to: Routes.invite_path(conn, :index))
  end

  def redeem(conn, _params) do
    render(conn, "redeem.html")
  end

  def register(conn, _params) do
    redirect(conn, to: Routes.channel_path(conn, :index))
  end
end
