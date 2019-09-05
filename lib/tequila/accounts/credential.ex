defmodule Tequila.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tequila.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "credentials" do
    belongs_to :user, User
    field :provider, :string
    field :token, :string
    field :uid, :string
    field :recovery_token, :string
    field :recovery_expires_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:uid, :token, :provider, :recovery_token, :recovery_expires_at])
    |> validate_required([:uid, :token, :provider])
    |> validate_length(:recovery_token, equal_to: 32)
  end
end
