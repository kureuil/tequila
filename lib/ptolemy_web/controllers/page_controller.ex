defmodule PtolemyWeb.PageController do
  use PtolemyWeb, :controller
  alias Ptolemy.Channels

  def index(conn, _params) do
    default_channel = Channels.get_default_for_user(conn.assigns[:current_user])
    redirect(conn, to: Routes.channel_path(conn, :show, default_channel))
  end
end
