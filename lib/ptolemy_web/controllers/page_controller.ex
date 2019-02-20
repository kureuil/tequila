defmodule PtolemyWeb.PageController do
  use PtolemyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
