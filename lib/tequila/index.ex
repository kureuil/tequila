defmodule Tequila.Index do
  @moduledoc """
  The Index context.
  """

  import Ecto.Query, warn: false
  alias Tequila.Repo

  alias Ecto.Changeset
  alias Tequila.Index.Link
  alias Tequila.Index.Submit
  alias Tequila.Accounts.User
  alias Tequila.Taxonomy
  alias Tequila.QueryParser

  @doc """
  Get the entries for the given search query.

  Returns `[]` if no entries matched the query.
  """
  def search!(query, opts \\ []) do
    limit = Keyword.get(opts, :per_page, 50) |> max(1) |> min(100)
    page = Keyword.get(opts, :page, 1) |> max(1)

    case QueryParser.parse(query) do
      {:ok, result, _, _, _, _} ->
        constraints = build_constraints(result)
        offset = (page - 1) * limit

        {:ok, [count | hits]} =
          Redix.command(:redix, [
            "FT.SEARCH",
            "tequila-links",
            constraints,
            "NOCONTENT",
            "SORTBY",
            "inserted_at",
            "DESC",
            "LIMIT",
            to_string(offset),
            to_string(limit + 1)
          ])

        has_next = count - offset > limit
        has_prev = page > 1
        hits = Enum.take(hits, limit)

        entries =
          Link
          |> where([l], l.id in ^hits)
          |> Repo.all()
          |> Enum.sort_by(fn entry -> Enum.find_index(hits, fn hit -> hit == entry.id end) end)

        {entries, has_next, has_prev}

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
      Redix.command!(:redix, ["FT.DEL", "tequila-links", link.id, "DD"])
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
          "tequila-links",
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
          "tequila-links",
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
