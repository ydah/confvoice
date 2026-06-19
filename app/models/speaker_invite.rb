class SpeakerInvite < ApplicationRecord
  DEFAULT_EXPIRATION = 14.days

  belongs_to :session

  has_secure_token :token

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :set_default_expiration, on: :create

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def conference
    session.conference
  end

  def active?
    revoked_at.blank? && expires_at.future?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  private

  def set_default_expiration
    self.expires_at ||= DEFAULT_EXPIRATION.from_now
  end
end
