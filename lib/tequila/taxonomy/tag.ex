defmodule Tequila.Taxonomy.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field :description, :string
    field :name, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
