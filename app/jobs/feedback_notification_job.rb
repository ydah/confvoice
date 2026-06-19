class FeedbackNotificationJob < ApplicationJob
  queue_as :default

  def perform(feedback)
    return unless feedback.speaker_visible?
    return unless feedback.session.speaker_user&.email_address?

    FeedbackMailer.with(feedback: feedback).speaker_notification.deliver_now
  end
end
