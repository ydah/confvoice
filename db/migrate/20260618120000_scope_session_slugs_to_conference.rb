class ScopeSessionSlugsToConference < ActiveRecord::Migration[8.1]
  def up
    remove_index :sessions, :slug

    execute <<~SQL.squish
      UPDATE sessions
      SET slug = substring(sessions.slug from char_length(conferences.slug) + 2)
      FROM conferences
      WHERE sessions.conference_id = conferences.id
        AND sessions.slug LIKE conferences.slug || '-%'
        AND NOT EXISTS (
          SELECT 1
          FROM sessions sibling_sessions
          WHERE sibling_sessions.conference_id = sessions.conference_id
            AND sibling_sessions.id <> sessions.id
            AND sibling_sessions.slug = substring(sessions.slug from char_length(conferences.slug) + 2)
        )
    SQL

    add_index :sessions, [:conference_id, :slug], unique: true
  end

  def down
    remove_index :sessions, [:conference_id, :slug]

    execute <<~SQL.squish
      UPDATE sessions
      SET slug = conferences.slug || '-' || sessions.slug
      FROM conferences
      WHERE sessions.conference_id = conferences.id
        AND sessions.slug NOT LIKE conferences.slug || '-%'
    SQL

    add_index :sessions, :slug, unique: true
  end
end
