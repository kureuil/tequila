defmodule PtolemyWeb.AuthPlug do
  import Plug.Conn
  require Ecto.Query
  alias Ptolemy.Repo
  alias Ptolemy.Accounts.User

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user =
      User
      |> Ecto.Query.where(email: "louis@person.guru")
      |> Repo.one()

    conn |> assign(:current_user, current_user)
  end
end
