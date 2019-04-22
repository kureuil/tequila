defmodule PtolemyWeb.LayoutView do
  use PtolemyWeb, :view

  alias Ptolemy.Channels

  def user_channels(current_user) do
    Channels.list_channels_by_user(current_user)
  end
end
