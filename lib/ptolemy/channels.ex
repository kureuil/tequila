defmodule Ptolemy.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Ptolemy.Repo

  alias Ecto.Changeset
  alias Ptolemy.Accounts.User
  alias Ptolemy.Channels.Channel

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels_by_user(%User{id: owner_id}) do
    Channel
    |> where(owner_id: ^owner_id)
    |> order_by(:inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc """
  Gets the default channel for the given user.

  Returns `nil` if the User has zero Channel.

  ## Examples

      iex> get_default_for_user(%User{})
      %Channel{}
  """
  def get_default_for_user(%User{id: owner_id}) do
    query = Channel |> where(owner_id: ^owner_id) |> where(default: true)
    fallback = Channel |> where(owner_id: ^owner_id) |> first
    # FIXME : possible race condition, should be able to insert if not found
    Repo.one(query) || Repo.one(fallback)
  end

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value}, Accounts.get_user!(123))
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value}, Accounts.get_user!(123))
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}, %User{} = owner) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Changeset.put_assoc(:owner, owner)
    |> Repo.insert()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{source: %Channel{}}

  """
  def change_channel(%Channel{} = channel) do
    Channel.changeset(channel, %{})
  end
end
