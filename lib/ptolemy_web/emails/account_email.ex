defmodule PtolemyWeb.AccountEmail do
  use Phoenix.Swoosh, view: PtolemyWeb.EmailView, layout: {PtolemyWeb.LayoutView, :email}

  import PtolemyWeb.Gettext

  alias Ptolemy.Accounts.User

  def password_recovery(user = %User{}, token) do
    url_config = PtolemyWeb.Endpoint.config(:url)

    base_uri = %URI{
      scheme: Keyword.get(url_config, :scheme, "http"),
      host: Keyword.get(url_config, :host),
      port: Keyword.get(url_config, :port),
      path: Keyword.get(url_config, :path)
    }

    new()
    |> to({user.email, user.email})
    |> from({"Ptolemy", "no-reply@ptolemy.particular.systems"})
    |> subject(gettext("[Ptolemy] Please reset your password"))
    |> text_body(
      Enum.join(
        [
          gettext("We heard that you lost your Ptolemy password. Sorry about that!"),
          gettext("But don’t worry! You can use the following link to reset your password:"),
          PtolemyWeb.Router.Helpers.password_reset_url(base_uri, :reset, token),
          gettext(
            "If you don’t use this link within 3 hours, it will expire. To get a new password reset link, visit %{url}",
            url: PtolemyWeb.Router.Helpers.password_reset_url(base_uri, :new)
          )
        ],
        "\n\n"
      )
    )
  end
end
