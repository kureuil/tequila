defmodule Ptolemy.Invites do
  @moduledoc """
  The Invites Context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Ptolemy.Repo
  alias Ptolemy.Invites.Invite
  alias Ptolemy.Invites.Redeem
  alias Ptolemy.Accounts
  alias Ptolemy.Accounts.User

  @doc """
  Lists all pending invites created by the given user.

  ## Examples

      iex> list_pending_by_owner(%User{})
      [%Invite{}, ...]

  """
  def list_pending_by_owner(%User{id: owner_id}) do
    Repo.all(
      from i in Invite,
        where: i.owner_id == ^owner_id,
        order_by: i.inserted_at
    )
  end

  def change_invite(%Invite{} = invite) do
    Invite.changeset(invite, %{})
  end

  def create_invite(attrs, %User{} = owner) do
    %Invite{}
    |> Invite.changeset(attrs)
    |> Changeset.put_assoc(:owner, owner)
    |> Repo.insert()
  end

  def find_for_redeem(id) do
    Repo.one(
      from i in Invite,
        where: i.id == ^id and i.inserted_at < datetime_add(i.inserted_at, 5, "day")
    )
  end

  def change_redeem(%Redeem{} = redeem) do
    Redeem.changeset(redeem, %{})
  end

  def delete_invite!(%Invite{} = invite) do
    Repo.delete!(invite)
  end

  def redeem(%Invite{} = invite, %{} = redeem_params) do
    case Redeem.changeset(%Redeem{}, redeem_params) do
      %{valid?: true} = changeset ->
        redeem = Changeset.apply_changes(changeset)

        case Repo.transaction(fn ->
          {:ok, user} = Accounts.create_user(Redeem.to_user(redeem))
          {:ok, _} = Accounts.create_credential(Redeem.to_credential(redeem), user)
          delete_invite!(invite)
          user
        end) do
          {:ok, user} ->
            {:ok, user}

          {:error, _} ->
            {:error, changeset}
        end

      changeset ->
        {:error, changeset}
    end
  end
end
