defmodule Tequila.Fixtures do
  import Ecto.Query

  alias Tequila.Repo

  alias Tequila.Accounts
  alias Tequila.Accounts.Credential
  alias Tequila.Invites.Invite

  def user(email) do
    try do
      Accounts.get_user_by_email!(email)
    rescue
      _ in Ecto.NoResultsError ->
        {:ok, user} = Accounts.create_user(%{email: email})
        user
    end
  end

  def credential(provider, uid, user) do
    query = from(c in Credential, where: c.provider == ^provider and c.uid == ^uid)

    Repo.one(query) ||
      Repo.insert!(%Credential{
        provider: provider,
        uid: uid,
        token: "supersecretpassword",
        user_id: user.id
      })
  end

  def invite(owner, inserted_at) do
    Repo.insert!(%Invite{
      owner_id: owner.id,
      invitee: Faker.Internet.email(),
      inserted_at: inserted_at |> DateTime.truncate(:second) |> DateTime.to_naive()
    })
  end
end
