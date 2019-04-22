defmodule Ptolemy.Index.Submit do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ptolemy.Index.Link
  alias Ptolemy.Taxonomy

  embedded_schema do
    field :location, :string
    field :title, :string
    field :description, :string
    field :tags, :string
  end

  def changeset(submit, attrs \\ %{}) do
    submit
    |> cast(attrs, [:location, :title, :description, :tags])
    |> validate_required([:location])
  end

  def to_link(submit) do
    struct(Link, Map.take(submit, [:location, :title, :description]))
  end

  def to_tags(submit) do
    (submit.tags || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn name -> String.length(name) > 1 end)
    |> Enum.map(fn name -> %Taxonomy.Tag{name: name} end)
  end
end
