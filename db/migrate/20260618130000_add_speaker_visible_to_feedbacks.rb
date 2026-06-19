class AddSpeakerVisibleToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :speaker_visible, :boolean, null: false, default: false
    add_index :feedbacks, [:session_id, :speaker_visible, :created_at]
  end
end
