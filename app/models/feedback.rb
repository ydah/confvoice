class Feedback < ApplicationRecord
  belongs_to :session, counter_cache: true

  scope :visible_to_speaker, -> { where(speaker_visible: true) }

  validates :respondent_name, presence: true, length: { maximum: 80 }
  validates :rating, allow_nil: true, inclusion: { in: 1..5, message: "は1〜5の範囲で入力してください" }
  validates :body, presence: true, length: { maximum: 2000 }
  validates :respondent_token, presence: true, uniqueness: {
    scope: :session_id,
    message: "このセッションには既に感想を送信済みです"
  }

  validate :session_accepting_feedback, on: :create

  after_create_commit :update_session_stats
  after_create_commit :broadcast_to_dashboard
  after_update_commit :notify_speaker, if: :became_visible_to_speaker?

  def share_with_speaker!
    update!(speaker_visible: true)
  end

  def hide_from_speaker!
    update!(speaker_visible: false)
  end

  private

  def session_accepting_feedback
    return if session&.feedback_open?

    errors.add(:base, "このセッションは感想の受付を終了しています")
  end

  def update_session_stats
    session.update_stats!
  end

  def broadcast_to_dashboard
    reloaded_session = session.reload

    broadcast_prepend_to(
      [session.conference, "feedbacks"],
      target: "feedbacks_list",
      partial: "feedbacks/feedback_card"
    )

    broadcast_replace_to(
      [session.conference, "stats"],
      target: "session_stats_#{session.id}",
      partial: "dashboards/session_stats",
      locals: { session: reloaded_session }
    )
  end

  def notify_speaker
    return unless session.speaker_user&.email_address?

    FeedbackNotificationJob.perform_later(self)
  end

  def became_visible_to_speaker?
    saved_change_to_speaker_visible? && speaker_visible?
  end
end
