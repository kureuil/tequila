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
  alias Ptolemy.QueryParser

  @doc """
  Get the entries for the given search query.

  Returns `[]` if no entries matched the query.
  """
  def search(query) do
    case QueryParser.parse(query) do
      {:ok, result, _, _, _, _} ->
        constraints = build_constraints(result)

        {:ok, [_count | hits]} =
          Redix.command(:redix, [
            "FT.SEARCH",
            "ptolemy-links",
            constraints,
            "NOCONTENT",
            "SORTBY",
            "inserted_at",
            "DESC",
            "LIMIT",
            "0",
            "50"
          ])

        Link
        |> where([l], l.id in ^hits)
        |> Repo.all()

      error ->
        throw(error)
    end
  end

  defp build_constraints([]), do: "*"

  defp build_constraints([root | []]), do: build_constraints(root)

  defp build_constraints({:word, word}) do
    "\"#{word}\""
  end

  defp build_constraints({:tag, tag}) do
    "(@tags:{#{tag}})"
  end

  defp build_constraints({:and, [clause, rest]}) do
    lhs = build_constraints(clause)
    rhs = build_constraints(rest)

    "(#{lhs} #{rhs})"
  end

  defp build_constraints({:or, [clause, rest]}) do
    lhs = build_constraints(clause)
    rhs = build_constraints(rest)

    "(#{lhs} | #{rhs})"
  end

  defp build_constraints({:not, clause}) do
    constraint = build_constraints(clause)

    "-#{constraint}"
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
    Repo.transaction(fn ->
      deleted = Repo.delete!(link)
      Redix.command!(:redix, ["FT.DEL", "ptolemy-links", link.id, "DD"])
      deleted
    end)
  end

  def change_submit(%Submit{} = submit) do
    Submit.changeset(submit, %{})
  end

  def create_submit(attrs, %User{} = author) do
    changeset = Submit.changeset(%Submit{}, attrs)

    if changeset.valid? do
      submit = Ecto.Changeset.apply_changes(changeset)

      tags = Submit.to_tags(submit) |> Taxonomy.upsert_tags()

      Repo.transaction(fn ->
        link =
          submit
          |> Submit.to_link()
          |> Link.changeset()
          |> Changeset.put_assoc(:author, author)
          |> Changeset.put_assoc(:tags, tags)
          |> Repo.insert!()

        tags = tags |> Enum.map(fn tag -> tag.name end) |> Enum.join(",")
        host = URI.parse(link.location).host

        Redix.command!(:redix, [
          "FT.ADD",
          "ptolemy-links",
          link.id,
          "1.0",
          "FIELDS",
          "location",
          link.location,
          "host",
          host,
          "title",
          link.title,
          "description",
          link.description,
          "author",
          author.id,
          "tags",
          tags,
          "inserted_at",
          link.inserted_at
        ])

        link
      end)
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

      Repo.transaction(fn ->
        link =
          Link.changeset(link, Map.from_struct(Submit.to_link(submit)))
          |> Changeset.put_assoc(:tags, tags)
          |> Repo.update!()

        tags = tags |> Enum.map(fn tag -> tag.name end) |> Enum.join(",")
        host = URI.parse(link.location).host

        Redix.command!(:redix, [
          "FT.ADD",
          "ptolemy-links",
          link.id,
          "1.0",
          "REPLACE",
          "FIELDS",
          "location",
          link.location,
          "host",
          host,
          "title",
          link.title,
          "description",
          link.description,
          "author",
          link.author_id,
          "tags",
          tags,
          "inserted_at",
          link.inserted_at
        ])

        link
      end)
    else
      changeset = %{changeset | action: :submit}
      {:error, changeset}
    end
  end
end
