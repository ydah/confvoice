class Session < ApplicationRecord
  belongs_to :conference
  belongs_to :speaker_user, class_name: "User", optional: true, inverse_of: :spoken_sessions
  has_many :feedbacks, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :speaker_invites, dependent: :destroy
  has_one_attached :slide_deck

  validates :title, :speaker_name, :starts_at, :ends_at, presence: true
  validates :slug, presence: true, uniqueness: { scope: :conference_id }, format: { with: SlugNormalizer::FORMAT }
  validate :ends_at_after_starts_at
  validate :ends_at_on_same_date
  validate :scheduled_within_conference_dates
  validate :slide_deck_must_be_pdf

  before_validation :generate_slug, on: :create

  scope :chronological, -> { order(starts_at: :asc, id: :asc) }
  scope :accepting_feedback, -> { where(feedback_open: true) }

  def to_param
    slug
  end

  def update_stats!
    update!(
      feedbacks_count: feedbacks.count,
      average_rating: feedbacks.average(:rating)&.round(2)
    )
  end

  def active_speaker_invite
    speaker_invites.active.order(expires_at: :desc).first
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = SlugNormalizer.normalize(title, fallback: "session")
    self.slug = unique_slug(base_slug.truncate(80, omission: ""))
  end

  def unique_slug(base_slug)
    candidate = base_slug
    suffix = 2

    while conference&.sessions&.where(slug: candidate)&.where.not(id: id)&.exists?
      candidate = "#{base_slug.truncate(72, omission: "")}-#{suffix}"
      suffix += 1
    end

    candidate
  end

  def ends_at_after_starts_at
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "は開始時刻より後にしてください") if ends_at <= starts_at
  end

  def ends_at_on_same_date
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "は開始日と同じ日付にしてください") if ends_at.to_date != starts_at.to_date
  end

  def scheduled_within_conference_dates
    return if conference.blank? || conference.starts_on.blank? || conference.ends_on.blank?

    conference_dates = conference.starts_on..conference.ends_on
    errors.add(:starts_at, "はカンファレンスの日程から選んでください") if starts_at.present? && !conference_dates.cover?(starts_at.to_date)
    errors.add(:ends_at, "はカンファレンスの日程から選んでください") if ends_at.present? && !conference_dates.cover?(ends_at.to_date)
  end

  def slide_deck_must_be_pdf
    return unless slide_deck.attached?

    if slide_deck.blob.content_type != "application/pdf"
      errors.add(:slide_deck, "はPDFを添付してください")
    end

    if slide_deck.blob.byte_size > 25.megabytes
      errors.add(:slide_deck, "は25MB以下にしてください")
    end
  end
end
