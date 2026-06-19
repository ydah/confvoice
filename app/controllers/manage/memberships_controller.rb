class Manage::MembershipsController < ApplicationController
  before_action :set_conference
  before_action :authorize_organizer
  before_action :set_membership, only: [:update, :destroy]

  def index
    @memberships = ordered_memberships
  end

  def create
    user = find_or_build_user
    return render_memberships(:unprocessable_entity) unless user.save

    membership = @conference.conference_memberships.find_or_initialize_by(user: user)
    membership.role = membership_role

    if membership.save
      redirect_to conference_manage_memberships_path(@conference), notice: "メンバーを追加しました"
    else
      @membership_errors = membership.errors.full_messages
      render_memberships(:unprocessable_entity)
    end
  end

  def update
    if @membership.update(role: membership_role)
      redirect_to conference_manage_memberships_path(@conference), notice: "メンバーを更新しました"
    else
      @membership_errors = @membership.errors.full_messages
      render_memberships(:unprocessable_entity)
    end
  end

  def destroy
    @membership.destroy
    redirect_to conference_manage_memberships_path(@conference), notice: "メンバーを削除しました"
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def set_membership
    @membership = @conference.conference_memberships.find(params[:id])
  end

  def authorize_organizer
    return if organizer_for?(@conference)

    redirect_to root_path, alert: "権限がありません"
  end

  def find_or_build_user
    email = membership_params[:email_address].to_s.strip.downcase
    user = User.find_or_initialize_by(email_address: email)
    return user unless user.new_record?

    assign_new_user_attributes(user)
    user
  end

  def assign_new_user_attributes(user)
    user.name = membership_params[:name].presence || membership_params[:email_address]
    user.role = membership_role == "organizer" ? :organizer : :audience
    user.password = password_for_new_user
    user.password_confirmation = user.password
  end

  def password_for_new_user
    return membership_params[:password] if membership_params[:password].present?
    return SecureRandom.base58(24) if membership_role == "speaker"

    @membership_errors = ["新規 Organizer にはパスワードを入力してください"]
    ""
  end

  def render_memberships(status)
    @memberships = ordered_memberships
    render :index, status: status
  end

  def ordered_memberships
    @conference.conference_memberships
      .joins(:user)
      .includes(:user)
      .order(:role)
      .order(User.arel_table[:name].asc)
  end

  def membership_params
    params.require(:conference_membership).permit(:email_address, :name, :password)
  end

  def membership_role
    role = params.require(:conference_membership)[:role].to_s
    return role if ConferenceMembership.roles.key?(role)

    "speaker"
  end
end
