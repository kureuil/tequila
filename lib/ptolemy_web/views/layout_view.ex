defmodule PtolemyWeb.LayoutView do
  use PtolemyWeb, :view

  alias Ptolemy.Channels

  def user_channels(current_user) do
    Channels.list_channels(current_user)
  end
end
