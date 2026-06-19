require "test_helper"

class SpeakerInviteTest < ActiveSupport::TestCase
  test "有効期限内の招待は有効" do
    invite = build(:speaker_invite, expires_at: 1.day.from_now)

    assert invite.active?
  end

  test "期限切れの招待は無効" do
    invite = build(:speaker_invite, expires_at: 1.minute.ago)

    assert_not invite.active?
  end

  test "無効化済みの招待は無効" do
    invite = build(:speaker_invite, revoked_at: Time.current)

    assert_not invite.active?
  end

  test "デフォルト有効期限は14日" do
    invite = create(:speaker_invite, expires_at: nil)

    assert_in_delta SpeakerInvite::DEFAULT_EXPIRATION.from_now.to_i, invite.expires_at.to_i, 2
  end
end
