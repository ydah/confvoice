require "test_helper"

class Manage::SessionsControllerTest < ActionDispatch::IntegrationTest
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
end
