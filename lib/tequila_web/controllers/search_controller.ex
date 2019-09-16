defmodule TequilaWeb.SearchController do
  use TequilaWeb, :controller

  alias Tequila.Index

  def index(conn, params) do
    page = Map.get(params, "page", "1")
    query = Map.get(params, "query", "")
    current_page = case Integer.parse(page) do
      {parsed, _rest} -> parsed
      :error -> 1
    end
    {entries, has_next, has_prev} = Index.search!(query, page: current_page)
    prev_page = max(current_page - 1, 1)
    next_page = current_page + 1
    render(conn, "results.html", query: query, entries: entries, has_next: has_next, has_prev: has_prev, prev_page: prev_page, next_page: next_page)
  end
end
