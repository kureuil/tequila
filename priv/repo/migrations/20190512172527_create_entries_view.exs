defmodule Ptolemy.Repo.Migrations.CreateEntriesView do
  use Ecto.Migration

  def change do
    execute """
            CREATE OR REPLACE VIEW entries AS
              SELECT DISTINCT ON (l.id) l.id, l.location, l.title, l.description, array_remove(array_agg(t.name), NULL) as tags
              FROM links l
              LEFT OUTER JOIN links_tags ON l.id = links_tags.link_id
              LEFT JOIN tags t ON t.id = links_tags.tag_id
              GROUP BY l.id
            ;
            """,
            """
            DROP VIEW IF EXISTS entries;
            """
  end
end
