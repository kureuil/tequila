defmodule Ptolemy.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ptolemy.Repo

  alias Ptolemy.Accounts.User
  alias Ptolemy.Accounts.Credential
  alias Ptolemy.Accounts.Session

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by its email.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("louis@person.guru")
      %User{}

      iex> get_user!("walouis@person.guru")
      ** (Ecto.NoResultsError)

  """
  def get_user_by_email!(email), do: Repo.one!(from u in User, where: u.email == ^email)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_by_email_and_pass(email, password) do
    credential =
      from(c in Credential, where: c.provider == "email" and c.uid == ^email) |> Repo.one()

    cond do
      credential && Pbkdf2.verify_pass(password, credential.token) ->
        Repo.insert(%Session{
          user_id: credential.user_id,
          credential_id: credential.id
        })

      credential ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def get_session!(id), do: Repo.get!(Session, id)

  def get_valid_session!(id),
    do: from(s in Session, where: is_nil(s.invalidated_at) and s.id == ^id) |> Repo.one!()

  def touch_session!(id) do
    changeset =
      Session.changeset(get_session!(id), %{
        updated_at: DateTime.utc_now()
      })

    Repo.update!(changeset)
  end

  def invalidate_session!(id) do
    changeset =
      Session.changeset(get_session!(id), %{
        invalidated_at: DateTime.utc_now()
      })

    Repo.update!(changeset)
  end
end
