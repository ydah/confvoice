require "csv"

class ExportsController < ApplicationController
  before_action :set_conference
  before_action :authorize_organizer

  def show
    feedbacks = Feedback.joins(:session)
      .where(sessions: { conference_id: @conference.id })
      .includes(:session)
      .order(created_at: :desc)

    if params[:speaker_name].present?
      speaker_name = params.expect(:speaker_name)
      @conference.sessions.find_by!(speaker_name: speaker_name)
      # shortcut: Names group speakers; use stable speaker IDs if names need disambiguation.
      feedbacks = feedbacks.where(sessions: { speaker_name: speaker_name })
    end

    csv_data = CSV.generate do |csv|
      csv << I18n.t("exports.headers").values
      feedbacks.each do |feedback|
        csv << [
          csv_cell(feedback.session.title),
          csv_cell(feedback.session.speaker_name),
          csv_cell(feedback.respondent_name),
          feedback.rating,
          csv_cell(feedback.body),
          feedback.created_at.strftime("%Y-%m-%d %H:%M")
        ]
      end
    end

    filename = [ @conference.slug, speaker_name, "feedbacks", Date.current ].compact.join("_") + ".csv"
    send_data "\uFEFF#{csv_data}",
      filename: ActiveStorage::Filename.new(filename).sanitized,
      type: "text/csv; charset=utf-8"
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: t("app.flash.forbidden")
  end

  def csv_cell(value)
    text = value.to_s
    return text unless text.match?(/\A[=+\-@\t\r\n]/)

    "'#{text}"
  end
end
