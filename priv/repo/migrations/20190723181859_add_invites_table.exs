defmodule Ptolemy.Repo.Migrations.AddInvitesTable do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :invitee, :string, null: false
      add :owner_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :redeemed_at, :utc_datetime, default: nil

      timestamps()
    end

    create index(:invites, [:owner_id])

    create index(:invites, [:owner_id, :invitee, :redeemed_at],
             where: "redeemed_at IS NULL",
             name: :no_concurrent_invites_per_email_and_owner
           )
  end
end
