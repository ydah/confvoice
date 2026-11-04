require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users cannot access the session list" do
    conference = create(:conference)

    get conference_sessions_path(conference)

    assert_redirected_to new_session_path
  end

  test "groups sessions by date and displays times without a room when none is set" do
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
    assert_no_match "Room TBD", response.body
    assert_select "a[href=?]", public_feedback_path(conference, session), text: "Send feedback"
  end

  test "organizers can view session details" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_session_path(conference, session)

    assert_response :success
  end

  test "speaker members cannot view organizer session details" do
    user = create(:user)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_session_path(conference, session)

    assert_redirected_to root_path
  end
end
