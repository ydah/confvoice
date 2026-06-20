class Manage::SessionsController < ApplicationController
  before_action :set_conference
  before_action :authorize_organizer
  before_action :set_session, only: [:show, :edit, :update, :destroy]

  def index
    @sessions = @conference.sessions.chronological
  end

  def show
  end

  def new
    @session = @conference.sessions.new
  end

  def create
    @session = @conference.sessions.new(session_params)

    if @session.save
      redirect_to conference_manage_sessions_path(@conference), notice: "セッションを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @session.update(session_params)
      redirect_to conference_manage_sessions_path(@conference), notice: "セッションを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @session.destroy
    redirect_to conference_manage_sessions_path(@conference), notice: "セッションを削除しました"
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def set_session
    @session = @conference.sessions.find_by!(slug: params[:id])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: "権限がありません"
  end

  def session_params
    params.require(:session).permit(
      :title,
      :description,
      :speaker_name,
      :speaker_user_id,
      :room,
      :scheduled_on,
      :starts_on,
      :starts_time,
      :starts_at,
      :ends_on,
      :ends_time,
      :ends_at,
      :feedback_open,
      :slide_deck
    ).tap do |permitted|
      permitted[:speaker_user_id] = nil if permitted[:speaker_user_id].blank?
      assign_session_datetimes(permitted)
    end
  end

  def assign_session_datetimes(attributes)
    date_value = attributes.delete(:scheduled_on).presence || attributes.delete(:starts_on)
    attributes.delete(:ends_on)
    starts_time = attributes.delete(:starts_time)
    ends_time = attributes.delete(:ends_time)
    return if date_value.blank? && starts_time.blank? && ends_time.blank?

    attributes[:starts_at] = parse_session_datetime(date_value, starts_time)
    attributes[:ends_at] = parse_session_datetime(date_value, ends_time)
  end

  def parse_session_datetime(date_value, time_value)
    return if date_value.blank? || time_value.blank?

    date = Date.iso8601(date_value.to_s)
    time = time_value.to_s.match(/\A(?<hour>[01]\d|2[0-3]):(?<minute>[0-5]\d)\z/)
    return unless time

    Time.zone.local(date.year, date.month, date.day, time[:hour].to_i, time[:minute].to_i)
  rescue ArgumentError
    nil
  end
end
