defmodule Mix.Tasks.SearchIndex do
  use Mix.Task

  @shortdoc "Create or update the search index in Redis"
  def run(_) do
    Mix.Task.run("app.start", [])

    last_version = last_version()

    case Redix.command(:redix, ["GET", "tequila-migration"]) do
      {:ok, ^last_version} ->
        IO.puts("Search index is already up-to-date, nothing to do.")

      {:ok, currentVersion} ->
        apply(currentVersion)

      {:err, err} ->
        IO.puts(
          :stderr,
          "An error occured while fetching the latest Redis migration version: #{err}"
        )
    end
  end

  defp apply(startFrom) do
    steps =
      case startFrom do
        nil ->
          all_steps()

        startFrom ->
          Enum.filter(all_steps(), fn step ->
            {version, _} = step
            version > startFrom
          end)
      end

    commands =
      Enum.map(steps, fn step ->
        {_, command} = step
        command
      end)

    {last_version, _} = Enum.at(steps, length(steps) - 1)

    version_upgrade = [["SET", "tequila-migration", last_version]]

    case Redix.transaction_pipeline(:redix, commands ++ version_upgrade) do
      {:ok, _} ->
        IO.puts("Successfully upgraded search index to version #{last_version}")

      {:err, error} ->
        IO.puts(:stderr, "An error occured while upgrading the search index: #{error}")
    end
  end

  defp last_version() do
    {version, _} = Enum.at(all_steps(), length(all_steps()) - 1)
    version
  end

  defp all_steps(),
    do: [
      {"2019-08-27 18:30:00Z",
       [
         "FT.CREATE",
         "tequila-links",
         "SCHEMA",
         "title",
         "TEXT",
         "WEIGHT",
         "3",
         "location",
         "TEXT",
         "NOSTEM",
         "WEIGHT",
         "0.5",
         "host",
         "TEXT",
         "NOINDEX",
         "description",
         "TEXT",
         "author",
         "TEXT",
         "NOINDEX",
         "tags",
         "TAG",
         "inserted_at",
         "TEXT",
         "NOSTEM",
         "NOINDEX",
         "SORTABLE"
       ]}
    ]
end
