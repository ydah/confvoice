require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "主催者はCSVをダウンロードできること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference)
    create(:feedback, session: session, respondent_name: "参加者 太郎", rating: nil, body: "良かった")

    sign_in_as(user)
    get conference_export_path(conference, format: :csv)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_includes response.body, "セッション"
    assert_includes response.body, "名前"
    assert_includes response.body, "参加者 太郎"
    assert_includes response.body, "良かった"
  end

  test "CSV出力では式として解釈される値をエスケープすること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference, role: :organizer)
    create(:feedback, session: session, respondent_name: "=cmd", rating: nil, body: "@danger")

    sign_in_as(user)
    get conference_export_path(conference, format: :csv)

    assert_response :success
    assert_includes response.body, "'=cmd"
    assert_includes response.body, "'@danger"
  end
end
