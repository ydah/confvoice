require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "accepts valid feedback" do
    feedback = build(:feedback)

    assert feedback.valid?
  end

  test "new feedback is not shared with speakers" do
    feedback = create(:feedback)

    assert_not feedback.speaker_visible?
  end

  test "does not enqueue a speaker notification when feedback is submitted" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)

    assert_no_enqueued_jobs only: FeedbackNotificationJob do
      create(:feedback, session: session)
    end
  end

  test "enqueues a notification when feedback is shared with the speaker" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)
    feedback = create(:feedback, session: session)

    assert_enqueued_jobs 1, only: FeedbackNotificationJob do
      feedback.share_with_speaker!
    end
  end

  test "rejects ratings outside the range of 1 to 5" do
    feedback = build(:feedback, rating: 6)

    assert_not feedback.valid?
    assert_includes feedback.errors[:rating], "must be between 1 and 5"
  end

  test "accepts feedback without a rating" do
    feedback = build(:feedback, rating: nil)

    assert feedback.valid?
  end

  test "requires a respondent name and feedback body" do
    feedback = build(:feedback, respondent_name: "", body: "")

    assert_not feedback.valid?
    assert_includes feedback.errors[:respondent_name], "can't be blank"
    assert_includes feedback.errors[:body], "can't be blank"
  end

  test "rejects duplicate feedback with the same session and respondent token" do
    existing = create(:feedback)
    duplicate = build(:feedback, session: existing.session, respondent_token: existing.respondent_token)

    assert_not duplicate.valid?
  end

  test "rejects feedback for sessions with closed submissions" do
    session = create(:session, feedback_open: false)
    feedback = build(:feedback, session: session)

    assert_not feedback.valid?
  end

  test "allows organizers to share feedback after submissions close" do
    feedback = create(:feedback)
    feedback.session.update!(feedback_open: false)

    assert_changes -> { feedback.reload.speaker_visible? }, from: false, to: true do
      feedback.share_with_speaker!
    end
  end
end
