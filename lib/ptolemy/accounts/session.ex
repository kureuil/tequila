defmodule Ptolemy.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions" do
    field :invalidated_at, :utc_datetime
    field :user_id, :binary_id
    field :credential_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:invalidated_at])
  end
end
