defmodule PtolemyWeb.PageController do
  use PtolemyWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.channel_path(conn, :index))
  end
end
