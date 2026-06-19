require "csv"

class ExportsController < ApplicationController
  before_action :set_conference
  before_action :authorize_organizer

  def show
    feedbacks = Feedback.joins(:session)
      .where(sessions: { conference_id: @conference.id })
      .includes(:session)
      .order(created_at: :desc)

    csv_data = CSV.generate do |csv|
      csv << ["セッション", "登壇者", "名前", "評価", "感想", "投稿日時"]
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

    send_data "\uFEFF#{csv_data}",
      filename: "#{@conference.slug}_feedbacks_#{Date.current}.csv",
      type: "text/csv; charset=utf-8"
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: "権限がありません"
  end

  def csv_cell(value)
    text = value.to_s
    return text unless text.match?(/\A[=+\-@\t\r\n]/)

    "'#{text}"
  end
end
