require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "未ログインではダッシュボードにアクセスできないこと" do
    conference = create(:conference)

    get conference_dashboard_path(conference)

    assert_redirected_to new_session_path
  end

  test "主催者はダッシュボードを閲覧できること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_dashboard_path(conference)

    assert_response :success
  end

  test "speakerメンバーはダッシュボードを閲覧できないこと" do
    user = create(:user)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_dashboard_path(conference)

    assert_redirected_to root_path
  end
end
