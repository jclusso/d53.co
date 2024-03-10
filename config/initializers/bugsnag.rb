return if Rails.env.local?

Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_API_KEY']
  config.release_stage = Rails.env
  config.enabled_release_stages = %w[production]
end
