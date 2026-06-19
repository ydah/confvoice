class AddRevokedAtToSpeakerInvites < ActiveRecord::Migration[8.1]
  def change
    add_column :speaker_invites, :revoked_at, :datetime
    add_index :speaker_invites, [:session_id, :revoked_at, :expires_at]
  end
end
