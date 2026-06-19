FactoryBot.define do
  factory :session do
    conference
    sequence(:title) { |number| "セッション #{number}" }
    description { "テスト用セッション" }
    speaker_name { "登壇者" }
    room { "Room 1" }
    starts_at { 1.day.from_now.change(sec: 0) }
    ends_at { starts_at + 50.minutes }
    feedback_open { true }
  end
end
