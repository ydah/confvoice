class ConferencesController < ApplicationController
  before_action :set_conference, only: [:show, :edit, :update, :destroy]
  before_action :authorize_organizer, only: [:show, :edit, :update, :destroy]

  def index
    @conferences = if current_user.admin?
      Conference.chronological
    else
      Conference
        .joins(:conference_memberships)
        .where(conference_memberships: { user: current_user, role: :organizer })
        .chronological
    end
  end

  def show
    @sessions = @conference.sessions.chronological
  end

  def new
    @conference = Conference.new
  end

  def create
    attributes = conference_params
    @conference = Conference.new(attributes.except(:remove_ogp_image))

    if @conference.save
      @conference.conference_memberships.find_or_create_by!(user: current_user) do |membership|
        membership.role = :organizer
      end

      redirect_to conference_path(@conference), notice: "カンファレンスを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = conference_params

    if @conference.update(attributes.except(:remove_ogp_image))
      @conference.ogp_image.purge if remove_ogp_image?(attributes)
      redirect_to conference_path(@conference), notice: "カンファレンスを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @conference.destroy
    redirect_to conferences_path, notice: "カンファレンスを削除しました"
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:slug])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: "権限がありません"
  end

  def conference_params
    permitted_attributes = [:name, :description, :venue, :starts_on, :ends_on, :published]
    permitted_attributes += [:ogp_image, :remove_ogp_image] if ogp_image_upload_enabled?

    params.require(:conference).permit(permitted_attributes)
  end

  def remove_ogp_image?(attributes)
    ActiveModel::Type::Boolean.new.cast(attributes[:remove_ogp_image])
  end
end
