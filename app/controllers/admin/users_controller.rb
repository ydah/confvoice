class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.order(:email_address)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = user_role if user_role.present?

    if @user.save
      redirect_to admin_user_path(@user), notice: "ユーザーを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = user_params
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?

    @user.assign_attributes(attributes)
    @user.role = user_role if user_role.present?

    if @user.save
      redirect_to admin_user_path(@user), notice: "ユーザーを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "自分自身は削除できません"
      return
    end

    @user.destroy
    redirect_to admin_users_path, notice: "ユーザーを削除しました"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email_address, :name, :password, :password_confirmation)
  end

  def user_role
    role = params.require(:user)[:role].to_s
    return unless User.roles.key?(role)

    role
  end
end
