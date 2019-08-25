defmodule PtolemyWeb.InviteEmail do
  use Phoenix.Swoosh, view: PtolemyWeb.EmailView, layout: {PtolemyWeb.LayoutView, :email}

  import PtolemyWeb.Gettext

  alias Ptolemy.Accounts.User
  alias Ptolemy.Invites.Invite

  def invite(%Invite{} = invite, %User{email: sender}) do
    url_config = PtolemyWeb.Endpoint.config(:url)

    base_uri = %URI{
      scheme: Keyword.get(url_config, :scheme, "http"),
      host: Keyword.get(url_config, :host),
      port: Keyword.get(url_config, :port),
      path: Keyword.get(url_config, :path)
    }

    instance = "ptolemy.particular.systems"

    new()
    |> to({invite.invitee, invite.invitee})
    |> from({"Ptolemy", "no-reply@ptolemy.particular.systems"})
    |> subject(gettext("[Ptolemy] You've been invited to %{instance}", instance: instance))
    |> text_body(
      Enum.join(
        [
          gettext("You've been invited to %{instance} by %{sender}",
            instance: instance,
            sender: sender
          ),
          gettext("In order to create your account, you need to click on the link below:"),
          PtolemyWeb.Router.Helpers.invite_url(base_uri, :redeem, invite.id),
          gettext(
            "If you don’t use this link within 5 days, it will expire. In that case, ask %{sender} to invite you again.",
            sender: sender
          )
        ],
        "\n\n"
      )
    )
  end
end
