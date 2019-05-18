defmodule Ptolemy.Index.Entry do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entries" do
    field :location, :string, null: false
    field :title, :string
    field :description, :string
    field :tags, {:array, :string}
  end
end

defimpl Elasticsearch.Document, for: Ptolemy.Index.Entry do
  def id(entry), do: entry.id
  def routing(_), do: false

  def encode(entry) do
    %{
      title: entry.title,
      description: entry.description,
      hostname: URI.parse(entry.location).host,
      tags: entry.tags
    }
  end
end
