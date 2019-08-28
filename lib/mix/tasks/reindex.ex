defmodule Mix.Tasks.Reindex do
  use Mix.Task

  import Ecto.Query

  alias Ptolemy.Repo
  alias Ptolemy.Index.Link

  @shortdoc "Reindex all content from the database into the search engine"
  def run(_) do
    Mix.Task.run("app.start", [])

    Repo.transaction(fn ->
      links = Repo.all(from(l in Link)) |> Repo.preload(:tags)

      Enum.each(links, fn link ->
        case Redix.command(:redix, [
               "FT.ADD",
               "ptolemy-links",
               link.id,
               "1.0",
               "REPLACE",
               "FIELDS",
               "location",
               link.location,
               "host",
               URI.parse(link.location).host,
               "title",
               link.title,
               "description",
               link.description,
               "author",
               link.author_id,
               "tags",
               link.tags |> Enum.map(fn tag -> tag.name end) |> Enum.join(","),
               "inserted_at",
               link.inserted_at
             ]) do
          {:err, error} ->
            IO.puts("Couldn't reindex link #{link.id}: #{error}")

          _ ->
            nil
        end
      end)
    end)
  end
end
