require "test_helper"

class FeedbackNotificationJobTest < ActiveJob::TestCase
  test "sends an email for shared feedback when the session has a speaker user" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)
    feedback = create(:feedback, :visible_to_speaker, session: session)

    assert_emails 1 do
      FeedbackNotificationJob.perform_now(feedback)
    end
  end

  test "does not notify the speaker user about unshared feedback" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)
    feedback = create(:feedback, session: session)

    assert_no_emails do
      FeedbackNotificationJob.perform_now(feedback)
    end
  end
end
