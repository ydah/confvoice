require "test_helper"

class PublicFeedbackFlowTest < ActionDispatch::IntegrationTest
  test "attendees can submit feedback" do
    session = create(:session, feedback_open: true)

    assert_equal "/#{session.conference.slug}/talks/#{ERB::Util.url_encode(session.slug)}", public_feedback_path(session.conference, session)

    get public_feedback_path(session.conference, session)
    assert_response :success
    assert_select "a[href=?]", public_conference_path(session.conference), text: "Back to talks"
    assert_select "form[data-controller=?][data-feedback-draft-key-value=?]", "feedback-draft", "feedback-draft:#{session.conference.slug}:#{session.slug}"
    assert_select "input[name=?][data-feedback-draft-target=?]", "feedback[respondent_name]", "field"
    assert_select "textarea[name=?][data-feedback-draft-target=?]", "feedback[body]", "field"
    assert_select "input[name=?]", "feedback[rating]", count: 0

    assert_difference "Feedback.count", 1 do
      post public_feedback_path(session.conference, session), params: {
        feedback: { respondent_name: "Taylor Smith", body: "Great session!" }
      }
    end
    assert_redirected_to public_feedback_thanks_path(session.conference, session)
    assert_equal "Taylor Smith", Feedback.last.respondent_name
    assert_nil Feedback.last.rating
  end

  test "escapes Japanese slugs in feedback submission URLs" do
    session = create(:session, title: "パフォーマンスチューニング", slug: nil)

    assert_equal "パフォーマンスチューニング", session.slug
    assert_includes public_feedback_path(session.conference, session), "%E3%83%91%E3%83%95"
  end

  test "rejects feedback for sessions with closed submissions" do
    session = create(:session, feedback_open: false)

    get public_feedback_path(session.conference, session)

    assert_response :forbidden
    assert_select "a[href=?]", public_conference_path(session.conference), text: "Back to talks"
  end
end
