FactoryBot.define do
  factory :conference do
    sequence(:name) { |number| "ConfVoice Summit #{number}" }
    description { "テスト用カンファレンス" }
    venue { "Hall A" }
    starts_on { Date.current }
    ends_on { Date.current + 1.day }
    sequence(:slug) { |number| "confvoice-summit-#{number}" }
    published { true }
  end
end
