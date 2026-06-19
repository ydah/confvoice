class PublicConferencesController < ApplicationController
  layout "public"

  skip_before_action :require_authentication
  before_action :set_conference

  def show
    @sessions = @conference.sessions.chronological
  end

  private

  def set_conference
    @conference = Conference.published.find_by!(slug: params[:slug])
  end
end
