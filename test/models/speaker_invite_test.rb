require "test_helper"

class SpeakerInviteTest < ActiveSupport::TestCase
  test "invitations are active before expiration" do
    invite = build(:speaker_invite, expires_at: 1.day.from_now)

    assert invite.active?
  end

  test "expired invitations are inactive" do
    invite = build(:speaker_invite, expires_at: 1.minute.ago)

    assert_not invite.active?
  end

  test "revoked invitations are inactive" do
    invite = build(:speaker_invite, revoked_at: Time.current)

    assert_not invite.active?
  end

  test "invitations expire after 14 days by default" do
    invite = create(:speaker_invite, expires_at: nil)

    assert_in_delta SpeakerInvite::DEFAULT_EXPIRATION.from_now.to_i, invite.expires_at.to_i, 2
  end
end
