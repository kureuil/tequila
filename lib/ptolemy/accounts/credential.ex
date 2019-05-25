defmodule Ptolemy.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "credentials" do
    field :provider, :string
    field :token, :string
    field :uid, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:uid, :token, :provider])
    |> validate_required([:uid, :token, :provider])
  end
end
