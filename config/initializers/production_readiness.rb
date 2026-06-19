if Rails.env.production?
  required_env = %w[DATABASE_URL RAILS_MASTER_KEY APP_HOST]
  missing_env = required_env.select { |key| ENV[key].blank? }

  if missing_env.any?
    raise "Missing required production environment variables: #{missing_env.join(', ')}"
  end
end
