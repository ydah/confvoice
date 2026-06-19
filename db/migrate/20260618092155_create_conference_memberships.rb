class CreateConferenceMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :conference_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :conference, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :conference_memberships, [:user_id, :conference_id], unique: true
  end
end
