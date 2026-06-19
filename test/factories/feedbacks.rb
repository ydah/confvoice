FactoryBot.define do
  factory :feedback do
    session
    respondent_name { "山田 太郎" }
    rating { 5 }
    body { "とても良かったです" }
    sequence(:respondent_token) { |number| "token-#{number}" }

    trait :visible_to_speaker do
      speaker_visible { true }
    end
  end
end
