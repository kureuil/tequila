defmodule TequilaWeb.LayoutView do
  use TequilaWeb, :view

  alias Tequila.Channels

  def user_channels(current_user) do
    Channels.list_channels_by_user(current_user)
  end
end
