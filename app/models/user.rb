class User < ApplicationRecord
  PASSWORD_MINIMUM_LENGTH = 12

  has_secure_password

  has_many :conference_memberships, dependent: :destroy
  has_many :conferences, through: :conference_memberships
  has_many :spoken_sessions, class_name: "Session", foreign_key: :speaker_user_id, dependent: :nullify, inverse_of: :speaker_user

  enum :role, { audience: 0, organizer: 1, admin: 2 }

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: PASSWORD_MINIMUM_LENGTH }, allow_nil: true
end
