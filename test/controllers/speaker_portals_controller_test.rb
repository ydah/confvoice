require "test_helper"

class SpeakerPortalsControllerTest < ActionDispatch::IntegrationTest
  test "allows access to the speaker portal with an active invitation" do
    invite = create(:speaker_invite)
    create(:feedback, :visible_to_speaker, session: invite.session)

    get speaker_portal_path(invite.token)

    assert_response :success
    assert_includes response.body, invite.session.title
  end

  test "only displays feedback shared by organizers in the speaker portal" do
    invite = create(:speaker_invite)
    create(:feedback, session: invite.session, body: "Feedback for organizers only")
    create(:feedback, :visible_to_speaker, session: invite.session, body: "Feedback shared with the speaker")

    get speaker_portal_path(invite.token)

    assert_response :success
    assert_includes response.body, "Feedback shared with the speaker"
    assert_no_match "Feedback for organizers only", response.body
    assert_select "#speaker_session_stats", text: /1/
  end

  test "rejects access through expired invitation links" do
    invite = create(:speaker_invite, expires_at: 1.minute.ago)

    get speaker_portal_path(invite.token)

    assert_response :gone
  end

  test "rejects access through revoked invitation links" do
    invite = create(:speaker_invite, revoked_at: Time.current)

    get speaker_portal_path(invite.token)

    assert_response :gone
  end
end
