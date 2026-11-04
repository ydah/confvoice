require "test_helper"

class QrcodesControllerTest < ActionDispatch::IntegrationTest
  test "organizers can view the QR code for the audience talk list" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)
    create(:session, conference: conference)

    sign_in_as(user)
    get conference_qrcodes_path(conference)

    assert_response :success
    assert_includes response.body, public_conference_url(conference)
    assert_includes response.body, "Audience talk list"
  end
end
