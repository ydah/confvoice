class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :session, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body
      t.string :respondent_token, null: false

      t.timestamps
    end

    add_index :feedbacks, [:session_id, :respondent_token], unique: true
  end
end
