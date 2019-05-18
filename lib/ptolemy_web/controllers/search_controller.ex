defmodule PtolemyWeb.SearchController do
  use PtolemyWeb, :controller

  alias Ptolemy.Index

  def index(conn, %{"q" => query}) do
    render(conn, "results.html", entries: Index.search(query))
  end

  def index(conn, _params) do
    render(conn, "no-query.html")
  end
end
