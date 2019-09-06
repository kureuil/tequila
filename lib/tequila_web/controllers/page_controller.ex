defmodule TequilaWeb.PageController do
  use TequilaWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.channel_path(conn, :index))
  end
end
