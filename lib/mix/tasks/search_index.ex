defmodule Mix.Tasks.SearchIndex do
  use Mix.Task

  @shortdoc "Create or update the search index in Redis"
  def run(_) do
    Mix.Task.run("app.start", [])

    Tequila.Release.migrate_redis()
  end
end
