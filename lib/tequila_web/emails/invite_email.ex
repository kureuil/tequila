defmodule TequilaWeb.InviteEmail do
  use Phoenix.Swoosh, view: TequilaWeb.EmailView, layout: {TequilaWeb.LayoutView, :email}

  import TequilaWeb.Gettext

  alias Tequila.Accounts.User
  alias Tequila.Invites.Invite

  def invite(%Invite{} = invite, %User{email: sender}) do
    base_uri = TequilaWeb.Endpoint.struct_url()

    instance = "tequila.particular.systems"

    new()
    |> to({invite.invitee, invite.invitee})
    |> from({"Tequila", "no-reply@tequila.particular.systems"})
    |> subject(gettext("[Tequila] You've been invited to %{instance}", instance: instance))
    |> text_body(
      Enum.join(
        [
          gettext("You've been invited to %{instance} by %{sender}",
            instance: instance,
            sender: sender
          ),
          gettext("In order to create your account, you need to click on the link below:"),
          TequilaWeb.Router.Helpers.invite_url(base_uri, :redeem, invite.id),
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
