class FeedbacksController < ApplicationController
  before_action :set_conference
  before_action :authorize_organizer
  before_action :set_session

  def index
    @feedbacks = @session.feedbacks.order(created_at: :desc)
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def set_session
    @session = @conference.sessions.find_by!(slug: params[:session_id])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: "権限がありません"
  end
end
