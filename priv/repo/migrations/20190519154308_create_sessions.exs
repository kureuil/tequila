defmodule Ptolemy.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :invalidated_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      add :credential_id, references(:credentials, on_delete: :nothing, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:sessions, [:user_id])
    create index(:sessions, [:credential_id])
  end
end
