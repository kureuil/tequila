defmodule Ptolemy.Invites do
  @moduledoc """
  The Invites Context.
  """

  import Ecto.Query, warn: false
  alias Ptolemy.Repo
  alias Ptolemy.Invites.Invite
  alias Ptolemy.Accounts.User

  @doc """
  Lists the invites created by the given user.

  ## Examples

      iex> list_by_owner(%User{})
      [%Invite{}, ...]

  """
  def list_by_owner(%User{} = _owner) do
    Repo.all(Invite)
  end

  def change_invite(%Invite{} = invite) do
    Invite.changeset(invite, %{})
  end
end
