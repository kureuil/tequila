defmodule Ptolemy.Invites.Redeem do
  use Ecto.Schema
  import Ecto.Changeset
  import PtolemyWeb.Gettext

  embedded_schema do
    field :email, :string
    field :password, :string
    field :password_confirmation, :string
  end

  @doc false
  def changeset(redeem, attrs \\ %{}) do
    redeem
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_length(:password, greater_than_or_equal_to: 8)
    |> validate_confirmation(:password, message: gettext("does not match password"))
  end

  def to_credential(%{email: email, password: password}) do
    %{
      provider: "email",
      uid: email,
      token: Pbkdf2.hash_pwd_salt(password)
    }
  end

  def to_user(%{email: email}) do
    %{
      email: email
    }
  end
end
