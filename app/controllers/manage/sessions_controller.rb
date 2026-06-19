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
      :starts_at,
      :ends_at,
      :feedback_open,
      :slide_deck
    ).tap do |permitted|
      permitted[:speaker_user_id] = nil if permitted[:speaker_user_id].blank?
    end
  end
end
