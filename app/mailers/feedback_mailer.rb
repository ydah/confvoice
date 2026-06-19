class FeedbackMailer < ApplicationMailer
  def speaker_notification
    @feedback = params[:feedback]
    @session = @feedback.session
    @conference = @session.conference

    mail(
      to: @session.speaker_user.email_address,
      subject: "[ConfVoice] #{@session.title} に新しい感想が届きました"
    )
  end
end
