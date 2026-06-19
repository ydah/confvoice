class DashboardsController < ApplicationController
  before_action :set_conference
  before_action :authorize_organizer

  def show
    @sessions = @conference.sessions.chronological
    @recent_feedbacks = Feedback.joins(:session)
      .where(sessions: { conference_id: @conference.id })
      .includes(:session)
      .order(created_at: :desc)
      .limit(20)
    @total_count = @sessions.sum(:feedbacks_count)
    @overall_average = @sessions.where.not(average_rating: nil).average(:average_rating)&.round(2)
    @feedbacks_by_day = Feedback.joins(:session)
      .where(sessions: { conference_id: @conference.id })
      .group_by_day(:created_at)
      .count
    @keywords = FeedbackKeywordExtractor.new(
      Feedback.joins(:session).where(sessions: { conference_id: @conference.id }).where.not(body: [nil, ""])
    ).top
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: "権限がありません"
  end
end
