require "test_helper"

class FeedbackSpeakerVisibilitiesControllerTest < ActionDispatch::IntegrationTest
  test "organizers can share feedback with speakers" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    feedback = create(:feedback, session: session)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    patch conference_session_feedback_speaker_visibility_path(conference, session, feedback)

    assert_redirected_to conference_session_feedbacks_path(conference, session)
    assert feedback.reload.speaker_visible?
  end

  test "organizers can stop sharing feedback with speakers" do
    user = create(:user, :organizer)
    conference = create(:conference)
    session = create(:session, conference: conference)
    feedback = create(:feedback, :visible_to_speaker, session: session)
    create(:conference_membership, user: user, conference: conference, role: :organizer)

    sign_in_as(user)
    delete conference_session_feedback_speaker_visibility_path(conference, session, feedback)

    assert_redirected_to conference_session_feedbacks_path(conference, session)
    assert_not feedback.reload.speaker_visible?
  end

  test "non-organizers cannot share feedback with speakers" do
    user = create(:user)
    conference = create(:conference)
    session = create(:session, conference: conference)
    feedback = create(:feedback, session: session)
    create(:conference_membership, user: user, conference: conference, role: :speaker)

    sign_in_as(user)
    patch conference_session_feedback_speaker_visibility_path(conference, session, feedback)

    assert_redirected_to root_path
    assert_not feedback.reload.speaker_visible?
  end
end
