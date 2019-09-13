defmodule TequilaWeb.AccountEmail do
  use Phoenix.Swoosh, view: TequilaWeb.EmailView, layout: {TequilaWeb.LayoutView, :email}

  import TequilaWeb.Gettext

  alias Tequila.Accounts.User

  def password_recovery(user = %User{}, token) do
    base_uri = TequilaWeb.Endpoint.struct_url()
    from_email = Application.get_env(:tequila, :public_email)

    new()
    |> to({user.email, user.email})
    |> from({"Tequila", from_email})
    |> subject(gettext("[Tequila] Please reset your password"))
    |> text_body(
      Enum.join(
        [
          gettext("We heard that you lost your Tequila password. Sorry about that!"),
          gettext("But don’t worry! You can use the following link to reset your password:"),
          TequilaWeb.Router.Helpers.password_reset_url(base_uri, :reset, token),
          gettext(
            "If you don’t use this link within 3 hours, it will expire. To get a new password reset link, visit %{url}",
            url: TequilaWeb.Router.Helpers.password_reset_url(base_uri, :new)
          )
        ],
        "\n\n"
      )
    )
  end
end
