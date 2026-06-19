Rack::Attack.throttle("requests/ip", limit: 60, period: 1.minute) do |req|
  req.ip
end

Rack::Attack.throttle("login/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.post? && req.path == "/session"
end

Rack::Attack.throttle("login/email", limit: 5, period: 1.minute) do |req|
  next unless req.post? && req.path == "/session"

  email = req.params["email_address"].to_s.strip.downcase
  "#{req.ip}:#{email}" if email.present?
end

Rack::Attack.throttle("feedback/token", limit: 5, period: 1.minute) do |req|
  feedback_path = req.path.match?(%r{\A/[^/]+/talks/[^/]+(?:/reactions)?\z})

  req.cookies["respondent_token"] if feedback_path && req.post?
end

Rack::Attack.throttled_responder = lambda do |_env|
  [429, { "Content-Type" => "text/plain; charset=utf-8" }, ["リクエストが多すぎます。しばらくしてからお試しください。"]]
end
