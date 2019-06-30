# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ptolemy.Repo.insert!(%Ptolemy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeds do
  alias Ptolemy.Repo
  alias Ptolemy.Accounts.User
  alias Ptolemy.Accounts.Credential
  alias Ptolemy.Channels.Channel
  alias Ptolemy.Index.Link
  alias Ptolemy.Taxonomy.Tag
  alias Ecto.Changeset
  import Ecto.Query, warn: false

  def user_find_or_create(email) do
    query = from u in User, where: u.email == ^email
    Repo.one(query) || Repo.insert!(%User{email: email})
  end

  def email_credential_find_or_create(%User{email: email} = user, password) do
    query = from c in Credential, where: c.provider == "email" and c.uid == ^email

    Repo.one(query) ||
      Repo.insert!(%Credential{
        provider: "email",
        uid: user.email,
        token: Pbkdf2.hash_pwd_salt(password),
        user_id: user.id
      })
  end

  def channel_find_or_create(name, channel_query, %User{id: owner_id}, default \\ false) do
    query = from c in Channel, where: c.name == ^name, where: c.owner_id == ^owner_id

    Repo.one(query) ||
      Repo.insert!(%Channel{
        name: name,
        query: channel_query,
        owner_id: owner_id,
        default: default
      })
  end

  def link_find_or_create(location, title, tags, %User{id: author_id}) do
    query = from l in Link, where: l.location == ^location, where: l.author_id == ^author_id

    link =
      Repo.one(query) ||
        Repo.insert!(%Link{
          location: location,
          title: title,
          author_id: author_id
        })

    tags =
      Enum.map(tags, fn tag ->
        query = from t in Tag, where: t.name == ^tag
        Repo.one(query) || Repo.insert!(%Tag{name: tag})
      end)

    link
    |> Repo.preload(:tags)
    |> Link.changeset()
    |> Changeset.put_assoc(:tags, tags)
    |> Repo.update!()
  end
end

user = Seeds.user_find_or_create("louis@person.guru")
Seeds.email_credential_find_or_create(user, "azertyuiop")

channels = [
  %{
    name: "Home",
    query: "",
    default: true
  },
  %{
    name: "Linux",
    query: "#linux not #nsfw"
  },
  %{
    name: "Windows",
    query: "#windows not #nsfw"
  },
  %{
    name: "Distributed Systems",
    query: "#distributedsystems not #nsfw"
  },
  %{
    name: "NSFW",
    query: "#nsfw"
  },
  %{
    name: "Games",
    query: "#games #gamedev"
  }
]

links = [
  %{
    location: "https://getsol.us/2019/03/17/solus-4-released/",
    title: "Solus 4 released",
    tags: ["linux", "solus", "os"]
  },
  %{
    location: "https://speakerdeck.com/elizarov/fresh-async-with-kotlin",
    title: "Fresh Async with Kotlin",
    tags: ["kotlin", "async", "coroutines"]
  },
  %{
    location:
      "https://medium.com/@marinsmiljanic/a-whirlwind-tour-of-distributed-systems-918d6632eb78",
    title: "A whirlwind tour of distributed systems",
    tags: ["distributedsystems", "beginner"]
  },
  %{
    location: "https://lwn.net/Articles/752188/",
    title: "Zero-Copy TCP Receive",
    tags: ["linux", "tcp", "network", "performance"]
  },
  %{
    location: "https://medium.com/airbnb-engineering/react-native-at-airbnb-f95aa460be1c",
    title: "React Native at AirBnB",
    tags: ["reactnative", "mobile", "airbnb"]
  },
  %{
    location:
      "https://arstechnica.com/gaming/2019/01/from-uncharted-to-obra-dinn-lucas-pope-dishes-on-his-illustrious-game-dev-career/",
    title: "From Uncharted to Obra Dinn: Lucas Pope dishes on his illustrious game-dev career",
    tags: ["interview", "games", "gamedesign", "papersplease", "obradinn"]
  },
  %{
    location: "https://pornhub.com/",
    title: "PornHub",
    tags: ["nsfw", "porn", "streaming"]
  }
]

Enum.map(channels, fn channel ->
  Seeds.channel_find_or_create(
    channel[:name],
    channel[:query],
    user,
    Map.get(channel, :default, false)
  )
end)

Enum.map(links, fn link ->
  Seeds.link_find_or_create(link[:location], link[:title], link[:tags], user)
end)
