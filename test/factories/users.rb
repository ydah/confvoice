FactoryBot.define do
  factory :user do
    sequence(:email_address) { |number| "user#{number}@example.com" }
    name { "テストユーザー" }
    password { "secure-test-password" }
    password_confirmation { "secure-test-password" }
    role { :organizer }

    trait :admin do
      role { :admin }
    end

    trait :organizer do
      role { :organizer }
    end

    trait :audience do
      role { :audience }
    end
  end
end
