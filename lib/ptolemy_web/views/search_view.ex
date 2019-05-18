defmodule PtolemyWeb.SearchView do
  use PtolemyWeb, :view

  def link_host(location) do
    uri = URI.parse(location)
    uri.host
  end
end
