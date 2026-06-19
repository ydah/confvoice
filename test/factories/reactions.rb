FactoryBot.define do
  factory :reaction do
    session
    kind { :thumbs_up }
    sequence(:respondent_token) { |number| "reaction-token-#{number}" }
  end
end
