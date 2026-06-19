class Reaction < ApplicationRecord
  belongs_to :session

  enum :kind, { thumbs_up: 0, fire: 1, idea: 2, thinking: 3 }

  validates :kind, presence: true
  validates :respondent_token, presence: true, uniqueness: { scope: [:session_id, :kind] }
  validate :session_accepting_feedback

  after_create_commit :broadcast_reaction_stats

  def self.emoji_for(kind)
    {
      "thumbs_up" => "👍",
      "fire" => "🔥",
      "idea" => "💡",
      "thinking" => "🤔"
    }.fetch(kind.to_s)
  end

  private

  def session_accepting_feedback
    return if session&.feedback_open?

    errors.add(:base, "このセッションはリアクションの受付を終了しています")
  end

  def broadcast_reaction_stats
    broadcast_replace_to(
      [session.conference, "stats"],
      target: "session_stats_#{session.id}",
      partial: "dashboards/session_stats",
      locals: { session: session.reload }
    )

    broadcast_replace_to(
      [session, "stats"],
      target: "speaker_session_stats",
      partial: "speaker_portals/session_stats",
      locals: { session: session.reload }
    )
  end
end
