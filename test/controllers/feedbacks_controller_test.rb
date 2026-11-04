require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "organizers can manage speaker sharing from the feedback list" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    feedback = create(:feedback, session: session)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    get conference_session_feedbacks_path(conference, session)

    assert_response :success
    assert_select "span", "Organizers only"
    assert_select "form[action=?]", conference_session_feedback_speaker_visibility_path(conference, session, feedback)
    assert_select "button", "Share with speaker"
    assert_select "a[href=?][data-turbo=false]", conference_export_path(conference, format: :csv, speaker_name: session.speaker_name), text: "Export speaker CSV"
  end

  test "speaker members cannot view the feedback list containing unshared feedback" do
    user = create(:user)
    conference = create(:conference)
    session = create(:session, conference: conference)
    create(:feedback, session: session, body: "Feedback for organizers only")
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    get conference_session_feedbacks_path(conference, session)

    assert_redirected_to root_path
  end
end
