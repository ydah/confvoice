class ConferenceMembership < ApplicationRecord
  belongs_to :user
  belongs_to :conference

  enum :role, { organizer: 0, speaker: 1 }

  validates :user_id, uniqueness: { scope: :conference_id }
end
