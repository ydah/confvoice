class CreateConferences < ActiveRecord::Migration[8.1]
  def change
    create_table :conferences do |t|
      t.string :name, null: false
      t.text :description
      t.string :venue
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :slug, null: false
      t.boolean :published, null: false, default: false

      t.timestamps
    end
    add_index :conferences, :slug, unique: true
  end
end
