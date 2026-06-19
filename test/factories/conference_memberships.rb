FactoryBot.define do
  factory :conference_membership do
    user
    conference
    role { :organizer }

    trait :speaker do
      role { :speaker }
    end
  end
end
