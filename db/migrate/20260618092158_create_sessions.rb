class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :conference, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :speaker_name, null: false
      t.bigint :speaker_user_id
      t.string :room
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :slug, null: false
      t.boolean :feedback_open, null: false, default: true
      t.integer :feedbacks_count, null: false, default: 0
      t.decimal :average_rating, precision: 3, scale: 2

      t.timestamps
    end
    add_index :sessions, :slug, unique: true
    add_index :sessions, :speaker_user_id
    add_foreign_key :sessions, :users, column: :speaker_user_id
  end
end
