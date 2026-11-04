require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users cannot access the dashboard" do
    conference = create(:conference)

    get conference_dashboard_path(conference)

    assert_redirected_to new_session_path
  end

  test "organizers can view the dashboard" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_dashboard_path(conference)

    assert_response :success
  end

  test "speaker members cannot view the dashboard" do
    user = create(:user)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_dashboard_path(conference)

    assert_redirected_to root_path
  end

  test "lists each conference speaker once in the CSV export selector" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create_list(:session, 2, conference: conference, speaker_name: "Speaker A")
    create(:session, conference: conference, speaker_name: "Speaker B")
    create(:session, speaker_name: "Speaker from another conference")
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_dashboard_path(conference)

    assert_response :success
    assert_select "a[href=?]", conference_export_path(conference, format: :csv), text: "Export CSV"
    assert_select "form[action=?][method=get][data-turbo=false]", conference_export_path(conference, format: :csv) do
      assert_select "label[for=speaker_name]", text: "Speaker name"
      assert_select "select[name=speaker_name][required]" do
        assert_select "option[value=?]", "Speaker A", count: 1
        assert_select "option[value=?]", "Speaker B", count: 1
        assert_select "option[value=?]", "Speaker from another conference", count: 0
      end
      assert_select "input[type=submit][value=?]", "Export speaker CSV"
    end
  end
end
