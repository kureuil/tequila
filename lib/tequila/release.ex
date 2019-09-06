defmodule Tequila.Release do
  @app :tequila

  def create_user(email) do
    Application.load(@app)
    {:ok, u} = Tequila.Accounts.create_user(%{email: email})
    pass_len = 32
    pass = :crypto.strong_rand_bytes(pass_len) |> Base.encode64 |> binary_part(0, pass_len) |> Pbkdf2.hash_pwd_salt()
    {:ok, _} = Tequila.Accounts.create_credential(%{
      uid: email,
      token: pass,
      provider: "email",
    }, u)
  end

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
    migrate_redis()
  end

  def migrate_redis do
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

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
