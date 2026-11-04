FactoryBot.define do
  factory :feedback do
    session
    respondent_name { "Alex Smith" }
    rating { 5 }
    body { "Great session" }
    sequence(:respondent_token) { |number| "token-#{number}" }

    trait :visible_to_speaker do
      speaker_visible { true }
    end
  end
end
