require "test_helper"

class QrcodesControllerTest < ActionDispatch::IntegrationTest
  test "主催者は参加者向けトーク一覧QRを確認できること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)
    create(:session, conference: conference)

    sign_in_as(user)
    get conference_qrcodes_path(conference)

    assert_response :success
    assert_includes response.body, public_conference_url(conference)
    assert_includes response.body, "参加者向けトーク一覧"
  end
end
