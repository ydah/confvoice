require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではセッション一覧にアクセスできないこと" do
    conference = create(:conference)

    get conference_sessions_path(conference)

    assert_redirected_to new_session_path
  end

  test "セッション一覧は日付ごとに時刻だけを表示し会場未設定なら表示しないこと" do
    user = create(:user, :organizer)
    conference = create(:conference, starts_on: Date.new(2026, 7, 18), ends_on: Date.new(2026, 7, 19))
    session = create(
      :session,
      conference: conference,
      title: "Opening Talk",
      room: nil,
      starts_at: Time.zone.local(2026, 7, 18, 10, 10),
      ends_at: Time.zone.local(2026, 7, 18, 10, 40)
    )
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_sessions_path(conference)

    assert_response :success
    assert_select "h2", "2026/07/18"
    assert_select "h3", "Opening Talk"
    assert_includes response.body, "10:10 - 10:40"
    assert_no_match "07/18 10:10 - 07/18 10:40", response.body
    assert_no_match "会場未定", response.body
    assert_select "a[href=?]", public_feedback_path(conference, session), text: "感想を送る"
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
