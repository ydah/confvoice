class PublicFeedbacksController < ApplicationController
  include PublicSessionScoping

  layout "public"

  skip_before_action :require_authentication
  before_action :set_session
  before_action :ensure_feedback_open, only: [:new, :create]

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = @session.feedbacks.build(feedback_params)
    @feedback.respondent_token = respondent_token

    if @feedback.save
      redirect_to public_feedback_thanks_path(@conference, @session)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
  end

  def closed
  end

  private

  def ensure_feedback_open
    return if @session.feedback_open?

    render :closed, status: :forbidden
  end

  def feedback_params
    params.require(:feedback).permit(:respondent_name, :body)
  end

  def respondent_token
    cookies.permanent[:respondent_token] ||= SecureRandom.urlsafe_base64(32)
  end
end
