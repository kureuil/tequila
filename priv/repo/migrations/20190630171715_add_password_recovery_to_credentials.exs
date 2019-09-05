defmodule Tequila.Repo.Migrations.AddPasswordRecoveryToCredentials do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      add :recovery_token, :text, null: true
      add :recovery_expires_at, :utc_datetime, null: true
    end

    create index(:credentials, [:recovery_token])
  end
end
