defmodule TequilaWeb.InviteView do
  use TequilaWeb, :view
  use Timex

  def relative_time(instant) do
    case Timex.format(instant, "{relative}", :relative) do
      {:ok, str} -> str
      _ -> ""
    end
  end
end
