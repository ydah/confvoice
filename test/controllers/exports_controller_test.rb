require "test_helper"
require "csv"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "主催者はCSVをダウンロードできること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference)
    create(:feedback, session: session, respondent_name: "参加者 太郎", rating: nil, body: "良かった")
    other_session = create(:session, conference: conference, speaker_name: "別の登壇者")
    create(:feedback, session: other_session, body: "別の登壇者への感想")

    sign_in_as(user)
    get conference_export_path(conference, format: :csv)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_includes response.body, "Session"
    assert_includes response.body, "Name"
    assert_includes response.body, "参加者 太郎"
    assert_includes response.body, "良かった"
    assert_includes response.body, "別の登壇者への感想"
    assert_includes response.headers["Content-Disposition"], "#{conference.slug}_feedbacks_#{Date.current}.csv"
  end

  test "登壇者を指定すると同じカンファレンスのその登壇者の全セッションをCSV出力すること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    speaker_name = "発表者 A"
    sessions = create_list(:session, 2, conference: conference, speaker_name: speaker_name)
    sessions.each { |session| create(:feedback, session: session, body: "@感想") }
    create(:feedback, session: create(:session, conference: conference, speaker_name: "別の登壇者"))
    create(:feedback, session: create(:session, speaker_name: speaker_name))
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(conference, format: :csv, speaker_name: speaker_name)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert response.body.start_with?("\uFEFF")
    rows = CSV.parse(response.body.delete_prefix("\uFEFF"), headers: true)
    assert_equal sessions.map(&:title).sort, rows.map { |row| row[0] }.sort
    assert_equal [ speaker_name ], rows.map { |row| row[1] }.uniq
    assert_equal [ "'@感想" ], rows.map { |row| row[4] }.uniq
    assert_includes CGI.unescape(response.headers["Content-Disposition"]), "#{conference.slug}_#{speaker_name}_feedbacks_#{Date.current}.csv"
  end

  test "別のカンファレンスにしかいない登壇者はCSV出力できないこと" do
    user = create(:user, :organizer)
    conference = create(:conference)
    other_session = create(:session, speaker_name: "別イベントの登壇者")
    create(:feedback, session: other_session)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(conference, format: :csv, speaker_name: other_session.speaker_name)

    assert_response :not_found
  end

  test "感想のない登壇者はヘッダーのみのCSVを出力できること" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:feedback, session: create(:session, conference: conference, speaker_name: "別の登壇者"))
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(conference, format: :csv, speaker_name: session.speaker_name)

    assert_response :success
    assert_equal [ I18n.t("exports.headers").values ], CSV.parse(response.body.delete_prefix("\uFEFF"))
  end

  test "登壇者名に配列を指定した場合はCSV出力を拒否すること" do
    user = create(:user, :organizer)
    session = create(:session)
    create(:conference_membership, user: user, conference: session.conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(session.conference, format: :csv, speaker_name: [ session.speaker_name ])

    assert_response :bad_request
  end

  test "未ログインでは登壇者のCSVを出力できないこと" do
    session = create(:session)

    get conference_export_path(session.conference, format: :csv, speaker_name: session.speaker_name)

    assert_redirected_to new_session_path
  end

  test "speakerメンバーは登壇者のCSVを出力できないこと" do
    user = create(:user)
    session = create(:session)
    create(:conference_membership, user: user, conference: session.conference, role: :speaker)

    sign_in_as(user)
    get conference_export_path(session.conference, format: :csv, speaker_name: session.speaker_name)

    assert_redirected_to root_path
  end

  test "別のカンファレンスの主催者は登壇者のCSVを出力できないこと" do
    user = create(:user, :organizer)
    session = create(:session)
    create(:conference_membership, user: user, role: :organizer)

    sign_in_as(user)
    get conference_export_path(session.conference, format: :csv, speaker_name: session.speaker_name)

    assert_redirected_to root_path
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
