if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"].blank?
  required_env = %w[DATABASE_URL RAILS_MASTER_KEY]
  required_env << "APP_HOST" if ENV["RENDER_EXTERNAL_HOSTNAME"].blank?
  missing_env = required_env.select { |key| ENV[key].blank? }

  if missing_env.any?
    raise "Missing required production environment variables: #{missing_env.join(', ')}"
  end
end
