class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions do |t|
      t.references :session, null: false, foreign_key: true
      t.integer :kind, null: false
      t.string :respondent_token, null: false

      t.timestamps
    end

    add_index :reactions, [:session_id, :kind, :respondent_token], unique: true
  end
end
