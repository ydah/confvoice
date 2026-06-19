module PublicSessionScoping
  extend ActiveSupport::Concern

  private

  def set_session
    @conference = Conference.published.find_by!(slug: params[:conference_slug])
    @session = @conference.sessions.find_by!(slug: params[:slug])
  end
end
