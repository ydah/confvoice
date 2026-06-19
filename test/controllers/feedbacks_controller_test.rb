require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "主催者は感想一覧で登壇者共有状態を操作できること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    feedback = create(:feedback, session: session)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_session_feedbacks_path(conference, session)

    assert_response :success
    assert_select "span", "主催者のみ"
    assert_select "form[action=?]", conference_session_feedback_speaker_visibility_path(conference, session, feedback)
    assert_select "button", "登壇者に共有"
  end

  test "speakerメンバーは未共有を含む感想一覧を閲覧できないこと" do
    user = create(:user)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:feedback, session: session, body: "主催者だけが見る感想")
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_session_feedbacks_path(conference, session)

    assert_redirected_to root_path
  end
end
