require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではセッション一覧にアクセスできないこと" do
    conference = create(:conference)

    get conference_sessions_path(conference)

    assert_redirected_to new_session_path
  end

  test "主催者はセッション詳細を閲覧できること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_session_path(conference, session)

    assert_response :success
  end

  test "speakerメンバーは主催者向けセッション詳細を閲覧できないこと" do
    user = create(:user)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_session_path(conference, session)

    assert_redirected_to root_path
  end
end
