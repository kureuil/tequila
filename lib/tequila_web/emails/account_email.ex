defmodule TequilaWeb.AccountEmail do
  use Phoenix.Swoosh, view: TequilaWeb.EmailView, layout: {TequilaWeb.LayoutView, :email}

  import TequilaWeb.Gettext

  alias Tequila.Accounts.User

  def password_recovery(user = %User{}, token) do
    url_config = TequilaWeb.Endpoint.config(:url)

    base_uri = %URI{
      scheme: Keyword.get(url_config, :scheme, "http"),
      host: Keyword.get(url_config, :host),
      port: Keyword.get(url_config, :port),
      path: Keyword.get(url_config, :path)
    }

    new()
    |> to({user.email, user.email})
    |> from({"Tequila", "support@particular.systems"})
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
