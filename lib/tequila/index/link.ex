defmodule Tequila.Index.Link do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tequila.Accounts.User
  alias Tequila.Taxonomy.Tag
  alias Tequila.Index.Submit

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "links" do
    field :location, :string, null: false
    field :title, :string
    field :description, :string
    belongs_to :author, User
    many_to_many :tags, Tag, join_through: "links_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(link, attrs \\ %{}) do
    link
    |> cast(attrs, [:location, :title, :description])
    |> validate_required([:location])
  end

  def to_submit(link) do
    tags =
      case link.tags do
        nil ->
          ""

        [] ->
          ""

        _ ->
          link.tags
          |> Enum.map(fn tag -> tag.name end)
          |> Enum.reduce(fn tag, acc -> acc <> ", " <> tag end)
      end

    %Submit{
      location: link.location,
      title: link.title,
      description: link.description,
      tags: tags
    }
  end
end
