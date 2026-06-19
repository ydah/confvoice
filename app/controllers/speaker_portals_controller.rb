class SpeakerPortalsController < ApplicationController
  skip_before_action :require_authentication
  before_action :set_invite

  def show
    return render :expired, status: :gone unless @invite.active?

    @invite.update!(accepted_at: Time.current) if @invite.accepted_at.blank?
    @session = @invite.session
    @conference = @session.conference
    visible_feedbacks = @session.feedbacks.visible_to_speaker
    @feedbacks = visible_feedbacks.order(created_at: :desc).limit(50)
    @feedback_count = visible_feedbacks.count
    @average_rating = visible_feedbacks.average(:rating)&.round(2)
    @keywords = FeedbackKeywordExtractor.new(visible_feedbacks.where.not(body: [nil, ""])).top
  end

  private

  def set_invite
    @invite = SpeakerInvite.find_by!(token: params[:token])
  end
end
