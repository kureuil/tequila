defmodule Ptolemy.Index do
  @moduledoc """
  The Index context.
  """

  import Ecto.Query, warn: false
  alias Ptolemy.Repo

  alias Ecto.Changeset
  alias Ptolemy.Index.Link
  alias Ptolemy.Index.Submit
  alias Ptolemy.Accounts.User
  alias Ptolemy.Taxonomy
  alias Ptolemy.Taxonomy.Tag

  @doc """
  Get the entries for the given channel.

  Returns `[]` if no entries matched the channel's query.
  """
  def search(query) do
    included_regex = ~r/#(?<name>[a-zA-Z]+)/
    excluded_regex = ~r/!(?<name>[a-zA-Z]+)/
    included_tags = Enum.map(Regex.scan(included_regex, query), fn [_c, name] -> name end)
    excluded_tags = Enum.map(Regex.scan(excluded_regex, query), fn [_c, name] -> name end)

    query =
      Link
      |> distinct(true)
      |> join(:inner, [l], t in assoc(l, :tags))

    query =
      case included_tags do
        [] -> query
        _ -> query |> where([l, t], t.name in ^included_tags)
      end

    query =
      case excluded_tags do
        [] -> query
        _ ->
          except_query = Link
          |> distinct(true)
          |> join(:inner, [l], t in assoc(l, :tags))
          |> where([l, t], t.name in ^excluded_tags)
          query |> except(^except_query)
      end

    subquery(query)
    |> order_by([l, t], desc: l.inserted_at)
    |> select([l, t], l)
    |> limit(50)
    |> Repo.all()
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(id), do: Repo.get!(Link, id) |> Repo.preload(:tags) |> Repo.preload(:author)

  @doc """
  Deletes a Link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  def change_submit(%Submit{} = submit) do
    Submit.changeset(submit, %{})
  end

  def create_submit(attrs, %User{} = author) do
    changeset = Submit.changeset(%Submit{}, attrs)

    if changeset.valid? do
      submit = Ecto.Changeset.apply_changes(changeset)

      tags = Submit.to_tags(submit) |> Taxonomy.upsert_tags()

      submit
      |> Submit.to_link()
      |> Link.changeset()
      |> Changeset.put_assoc(:author, author)
      |> Changeset.put_assoc(:tags, tags)
      |> Repo.insert()
    else
      changeset = %{changeset | action: :submit}
      {:error, changeset}
    end
  end

  def update_submit(link, attrs \\ %{}) do
    changeset = Submit.changeset(%Submit{}, attrs)

    if changeset.valid? do
      submit = Ecto.Changeset.apply_changes(changeset)

      tags = Submit.to_tags(submit) |> Taxonomy.upsert_tags()

      Link.changeset(link, Map.from_struct(Submit.to_link(submit)))
      |> Changeset.put_assoc(:tags, tags)
      |> Repo.update()
    else
      changeset = %{changeset | action: :submit}
      {:error, changeset}
    end
  end
end
