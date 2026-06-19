class PagesController < ApplicationController
  skip_before_action :require_authentication

  def home
    @conferences = Conference.published.chronological.limit(6)
  end
end
