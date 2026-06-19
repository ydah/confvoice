if Rails.env.production? && ENV["ALLOW_PRODUCTION_SEEDS"] != "true"
  abort "Refusing to run seed data in production. Set ALLOW_PRODUCTION_SEEDS=true only for an intentional one-time bootstrap."
end

puts "Creating seed data..."

seed_password = ENV.fetch("CONFVOICE_SEED_PASSWORD", "confvoice-local-password")

admin = User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.password = seed_password
  user.password_confirmation = seed_password
  user.name = "管理者"
  user.role = :admin
end

organizer = User.find_or_create_by!(email_address: "organizer@example.com") do |user|
  user.password = seed_password
  user.password_confirmation = seed_password
  user.name = "山田太郎"
  user.role = :organizer
end

speaker = User.find_or_create_by!(email_address: "speaker@example.com") do |user|
  user.password = seed_password
  user.password_confirmation = seed_password
  user.name = "登壇者サンプル"
  user.role = :audience
end

conference = Conference.find_by(slug: "rubykaigi2026") || Conference.new
conference.assign_attributes(
  slug: "rubykaigi2026",
  name: "RubyKaigi 2026",
  description: "日本最大の Ruby カンファレンス",
  venue: "東京国際フォーラム",
  starts_on: Date.new(2026, 9, 10),
  ends_on: Date.new(2026, 9, 12),
  published: true
)
conference.save!

ConferenceMembership.find_or_create_by!(user: organizer, conference: conference) do |membership|
  membership.role = :organizer
end

ConferenceMembership.find_or_create_by!(user: admin, conference: conference) do |membership|
  membership.role = :organizer
end

ConferenceMembership.find_or_create_by!(user: speaker, conference: conference) do |membership|
  membership.role = :speaker
end

sessions_data = [
  { title: "Keynote: Ruby の未来", slug: "keynote-ruby", speaker: "まつもとゆきひろ", room: "Hall A", hour: 10 },
  { title: "Rails 8.1 の新機能", slug: "rails-8-1", speaker: "DHH", room: "Hall A", hour: 11 },
  { title: "Hotwire 実践入門", slug: "hotwire", speaker: "鈴木一郎", room: "Hall B", hour: 13 },
  { title: "パフォーマンスチューニング", slug: "performance-tuning", speaker: "田中花子", room: "Hall B", hour: 14 },
  { title: "テスト駆動開発のすすめ", slug: "test-driven-development", speaker: "佐藤次郎", room: "Hall A", hour: 15 }
]

sessions = sessions_data.map do |data|
  session = Session.find_or_initialize_by(conference: conference, title: data[:title])
  session.slug = data[:slug]
  session.speaker_name = data[:speaker]
  session.speaker_user = speaker if data[:title] == "Hotwire 実践入門"
  session.room = data[:room]
  session.starts_at = Time.zone.local(2026, 9, 10, data[:hour], 0)
  session.ends_at = Time.zone.local(2026, 9, 10, data[:hour], 50)
  session.feedback_open = true
  session.save!
  session
end

sample_bodies = [
  "実務で使うイメージが湧きました。",
  "テンポが良く、要点が分かりやすかったです。",
  "もう少しコード例を見たいです。",
  "明日から試したい内容でした。"
]

sessions.each_with_index do |session, session_index|
  3.times do |index|
    Feedback.find_or_create_by!(
      session: session,
      respondent_token: "seed-#{session_index}-#{index}"
    ) do |feedback|
      feedback.respondent_name = "参加者#{index + 1}"
      feedback.rating = 3 + ((session_index + index) % 3)
      feedback.body = sample_bodies[(session_index + index) % sample_bodies.length]
    end
  end
  Reaction.kinds.keys.each_with_index do |kind, index|
    Reaction.find_or_create_by!(
      session: session,
      kind: kind,
      respondent_token: "seed-reaction-#{session_index}-#{index}"
    )
  end
  session.speaker_invites.create! if session_index.zero? && session.speaker_invites.none?
  session.update_stats!
end

puts "Seed data created!"
puts "  Admin:     admin@example.com / #{seed_password}"
puts "  Organizer: organizer@example.com / #{seed_password}"
puts "  Speaker:   speaker@example.com / #{seed_password}"
puts "  Conference: #{conference.name} (#{conference.sessions.count} sessions)"
