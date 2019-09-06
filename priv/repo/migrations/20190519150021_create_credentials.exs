defmodule Tequila.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :uid, :string, null: false
      add :token, :string, null: false
      add :provider, :string, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:credentials, [:user_id])
    create unique_index(:credentials, [:user_id, :provider])
    create unique_index(:credentials, [:provider, :uid])
  end
end
