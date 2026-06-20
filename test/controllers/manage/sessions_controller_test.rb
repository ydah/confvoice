require "test_helper"

class Manage::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "セッションフォームの日付はカンファレンス日程から選べること" do
    user = create(:user, :organizer)
    conference = create(:conference, starts_on: Date.new(2026, 6, 20), ends_on: Date.new(2026, 6, 22))
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get new_conference_manage_session_path(conference)

    assert_response :success
    assert_select "select[name=?]", "session[starts_on]" do
      assert_select "option", count: 3
      assert_select "option[value=?]", "2026-06-20"
      assert_select "option[value=?]", "2026-06-21"
      assert_select "option[value=?]", "2026-06-22"
      assert_select "option[value=?]", "2026-06-23", count: 0
    end
    assert_select "input[type=time][name=?]", "session[starts_time]"
  end

  test "主催者が作成するセッションのslugはタイトルから自動生成されること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    post conference_manage_sessions_path(conference), params: {
      session: {
        title: "Keynote: Ruby の未来",
        description: "基調講演",
        speaker_name: "Matz",
        room: "Main Hall",
        starts_at: 1.day.from_now.change(sec: 0),
        ends_at: 1.day.from_now.change(sec: 0) + 50.minutes,
        slug: "manual-slug",
        feedback_open: "1"
      }
    }

    assert_redirected_to conference_manage_sessions_path(conference)
    assert_equal "keynote-ruby-の未来", conference.sessions.order(:created_at).last.slug
  end

  test "主催者はカンファレンス日程から選んだ日付と時刻でセッションを作成できること" do
    user = create(:user, :organizer)
    conference = create(:conference, starts_on: Date.new(2026, 6, 20), ends_on: Date.new(2026, 6, 21))
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    post conference_manage_sessions_path(conference), params: {
      session: {
        title: "Keynote: Ruby の未来",
        description: "基調講演",
        speaker_name: "Matz",
        room: "Main Hall",
        starts_on: "2026-06-20",
        starts_time: "10:30",
        ends_on: "2026-06-20",
        ends_time: "11:20",
        feedback_open: "1"
      }
    }

    session = conference.sessions.order(:created_at).last

    assert_redirected_to conference_manage_sessions_path(conference)
    assert_equal Time.zone.local(2026, 6, 20, 10, 30), session.starts_at
    assert_equal Time.zone.local(2026, 6, 20, 11, 20), session.ends_at
  end
end
