defmodule Ptolemy.Repo.Migrations.AddInvitesTable do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :invitee, :string, null: false
      add :owner_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:invites, [:owner_id])

    create index(:invites, [:owner_id, :invitee],
             unique: true,
             name: :no_concurrent_invites_per_email_and_owner
           )
  end
end
