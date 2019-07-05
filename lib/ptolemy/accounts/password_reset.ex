defmodule Ptolemy.Accounts.PasswordReset do
  use Ecto.Schema
  import Ecto.Changeset
  import PtolemyWeb.Gettext

  embedded_schema do
    field :password, :string
    field :password_confirmation, :string
  end

  @doc false
  def changeset(password_reset, attrs \\ %{}) do
    password_reset
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, greater_than_or_equal_to: 8)
    |> validate_confirmation(:password, message: gettext("does not match password"))
  end
end
