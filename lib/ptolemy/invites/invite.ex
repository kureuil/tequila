defmodule Ptolemy.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ptolemy.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invites" do
    belongs_to :owner, User
    field :invitee, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:invitee])
    |> validate_required([:invitee])
    |> validate_format(:invitee, ~r/@/)
    |> unique_constraint(:invitee, name: :no_concurrent_invites_per_email_and_owner)
  end
end
