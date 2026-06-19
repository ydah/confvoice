require "test_helper"

class FeedbackNotificationJobTest < ActiveJob::TestCase
  test "共有済みでspeaker_userがいる場合は通知メールを送ること" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)
    feedback = create(:feedback, :visible_to_speaker, session: session)

    assert_emails 1 do
      FeedbackNotificationJob.perform_now(feedback)
    end
  end

  test "未共有の感想はspeaker_userがいても通知しないこと" do
    speaker = create(:user, email_address: "speaker-notify@example.com")
    session = create(:session, speaker_user: speaker)
    feedback = create(:feedback, session: session)

    assert_no_emails do
      FeedbackNotificationJob.perform_now(feedback)
    end
  end
end
