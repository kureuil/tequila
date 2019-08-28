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
