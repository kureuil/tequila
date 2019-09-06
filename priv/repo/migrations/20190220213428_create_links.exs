defmodule Tequila.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :location, :string, null: false
      add :title, :string
      add :description, :string
      add :author_id, references(:users, on_delete: :nilify_all, type: :binary_id), null: false

      timestamps()
    end
  end
end
