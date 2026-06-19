require "test_helper"

class SpeakerPortalsControllerTest < ActionDispatch::IntegrationTest
  test "有効な招待リンクでSpeakerポータルを閲覧できること" do
    invite = create(:speaker_invite)
    create(:feedback, :visible_to_speaker, session: invite.session)

    get speaker_portal_path(invite.token)

    assert_response :success
    assert_includes response.body, invite.session.title
  end

  test "Speakerポータルには主催者が共有した感想だけ表示すること" do
    invite = create(:speaker_invite)
    create(:feedback, session: invite.session, body: "主催者だけが見る感想")
    create(:feedback, :visible_to_speaker, session: invite.session, body: "登壇者に共有する感想")

    get speaker_portal_path(invite.token)

    assert_response :success
    assert_includes response.body, "登壇者に共有する感想"
    assert_no_match "主催者だけが見る感想", response.body
    assert_select "#speaker_session_stats", text: /1/
  end

  test "期限切れ招待リンクは閲覧できないこと" do
    invite = create(:speaker_invite, expires_at: 1.minute.ago)

    get speaker_portal_path(invite.token)

    assert_response :gone
  end

  test "無効化済み招待リンクは閲覧できないこと" do
    invite = create(:speaker_invite, revoked_at: Time.current)

    get speaker_portal_path(invite.token)

    assert_response :gone
  end
end
