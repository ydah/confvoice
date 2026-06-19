class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "ConfVoice <no-reply@example.com>")
  layout "mailer"
end
