class PublicReactionsController < ApplicationController
  include PublicSessionScoping

  skip_before_action :require_authentication
  before_action :set_session

  def create
    reaction = @session.reactions.build(kind: reaction_params[:kind], respondent_token: respondent_token)

    if reaction.save
      redirect_to public_feedback_path(@conference, @session), notice: "リアクションを送信しました"
    else
      redirect_to public_feedback_path(@conference, @session), alert: reaction.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to public_feedback_path(@conference, @session), alert: "このリアクションは送信済みです"
  end

  private

  def reaction_params
    params.require(:reaction).permit(:kind)
  end

  def respondent_token
    cookies.permanent[:respondent_token] ||= SecureRandom.urlsafe_base64(32)
  end
end
