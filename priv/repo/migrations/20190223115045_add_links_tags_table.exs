defmodule Tequila.Repo.Migrations.AddLinksTagsTable do
  use Ecto.Migration

  def change do
    create table(:links_tags, primary_key: false) do
      add :link_id, references(:links, on_delete: :delete_all, type: :binary_id),
        null: false,
        primary_key: true

      add :tag_id, references(:tags, on_delete: :delete_all, type: :binary_id),
        null: false,
        primary_key: true
    end
  end
end
