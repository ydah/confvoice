FactoryBot.define do
  factory :speaker_invite do
    session
    expires_at { SpeakerInvite::DEFAULT_EXPIRATION.from_now }
  end
end
