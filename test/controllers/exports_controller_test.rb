require "test_helper"
require "csv"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "organizers can download feedback as CSV" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:conference_membership, user: user, conference: conference)
    create(:feedback, session: session, respondent_name: "Taylor Smith", rating: nil, body: "Great talk")
    other_session = create(:session, conference: conference, speaker_name: "Another Speaker")
    create(:feedback, session: other_session, body: "Feedback for another speaker")

    sign_in_as(user)
    get conference_export_path(conference, format: :csv)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_includes response.body, "Session"
    assert_includes response.body, "Name"
    assert_includes response.body, "Taylor Smith"
    assert_includes response.body, "Great talk"
    assert_includes response.body, "Feedback for another speaker"
    assert_includes response.headers["Content-Disposition"], "#{conference.slug}_feedbacks_#{Date.current}.csv"
  end

  test "exports feedback for all sessions by the selected speaker within the conference" do
    user = create(:user, :organizer)
    conference = create(:conference)
    speaker_name = "Zoë Morgan"
    sessions = create_list(:session, 2, conference: conference, speaker_name: speaker_name)
    sessions.each { |session| create(:feedback, session: session, body: "@feedback") }
    create(:feedback, session: create(:session, conference: conference, speaker_name: "Another Speaker"))
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
    assert_equal [ "'@feedback" ], rows.map { |row| row[4] }.uniq
    assert_includes CGI.unescape(response.headers["Content-Disposition"]), "#{conference.slug}_#{speaker_name}_feedbacks_#{Date.current}.csv"
  end

  test "rejects CSV exports for speakers who only appear in another conference" do
    user = create(:user, :organizer)
    conference = create(:conference)
    other_session = create(:session, speaker_name: "Speaker from another conference")
    create(:feedback, session: other_session)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(conference, format: :csv, speaker_name: other_session.speaker_name)

    assert_response :not_found
  end

  test "exports only the CSV header for a speaker without feedback" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:feedback, session: create(:session, conference: conference, speaker_name: "Another Speaker"))
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(conference, format: :csv, speaker_name: session.speaker_name)

    assert_response :success
    assert_equal [ I18n.t("exports.headers").values ], CSV.parse(response.body.delete_prefix("\uFEFF"))
  end

  test "rejects CSV exports when the speaker name is an array" do
    user = create(:user, :organizer)
    session = create(:session)
    create(:conference_membership, user: user, conference: session.conference, role: :organizer)

    sign_in_as(user)
    get conference_export_path(session.conference, format: :csv, speaker_name: [ session.speaker_name ])

    assert_response :bad_request
  end

  test "unauthenticated users cannot export speaker feedback as CSV" do
    session = create(:session)

    get conference_export_path(session.conference, format: :csv, speaker_name: session.speaker_name)

    assert_redirected_to new_session_path
  end

  test "speaker members cannot export speaker feedback as CSV" do
    user = create(:user)
    session = create(:session)
    create(:conference_membership, user: user, conference: session.conference, role: :speaker)

    sign_in_as(user)
    get conference_export_path(session.conference, format: :csv, speaker_name: session.speaker_name)

    assert_redirected_to root_path
  end

  test "organizers of another conference cannot export speaker feedback as CSV" do
    user = create(:user, :organizer)
    session = create(:session)
    create(:conference_membership, user: user, role: :organizer)

    sign_in_as(user)
    get conference_export_path(session.conference, format: :csv, speaker_name: session.speaker_name)

    assert_redirected_to root_path
  end

  test "escapes CSV values that could be interpreted as formulas" do
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
