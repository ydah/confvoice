class CreateSpeakerInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :speaker_invites do |t|
      t.references :session, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end
    add_index :speaker_invites, :token, unique: true
  end
end
