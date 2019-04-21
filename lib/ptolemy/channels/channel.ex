defmodule Ptolemy.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ptolemy.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "channels" do
    field :name, :string, null: false
    field :query, :string, null: false, default: ""
    field :default, :boolean, null: false, default: false
    belongs_to :owner, User

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :query, :default])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :channels_unique_name_per_owner_id)
    |> unique_constraint(:default, name: :channels_unique_default_per_owner_id)
  end
end
