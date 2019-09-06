defmodule TequilaWeb.SearchController do
  use TequilaWeb, :controller

  alias Tequila.Index

  def index(conn, %{"q" => query}) do
    render(conn, "results.html", entries: Index.search(query))
  end

  def index(conn, _params) do
    render(conn, "no-query.html")
  end
end
