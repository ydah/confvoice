class AddRespondentNameToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :respondent_name, :string, null: false, default: ""
    change_column_null :feedbacks, :rating, true
  end
end
