defmodule Tequila.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :query, :string, null: false
      add :default, :boolean, null: false, default: false
      add :owner_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:channels, [:owner_id])
    create unique_index(:channels, [:name, :owner_id], name: :channels_unique_name_per_owner_id)

    create unique_index(:channels, [:default, :owner_id],
             name: :channels_unique_default_per_owner_id,
             where: "channels.default = true"
           )
  end
end
