# config/environments/production.rb

Rails.application.configure do
  # Ensure secret_key_base is set even during assets precompile or db tasks
  secret = ENV['SECRET_KEY_BASE'] || 'dummy_secret_for_assets'
  config.secret_key_base = secret

  # Eager load code
  config.eager_load = true

  # Disable full error reports
  config.consider_all_requests_local = false

  # Caching
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store

  # Serve static assets
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Force SSL if not disabled
  config.force_ssl = ENV['DISABLE_SSL'].blank?

  # Logging
  config.log_level = :info

  # Active Storage
  config.active_storage.service = :local

  # Active Job adapter
  config.active_job.queue_adapter = :resque

  # I18n fallback
  config.i18n.fallbacks = true

  # Do not dump schema after migrations
  config.active_record.dump_schema_after_migration = false
end
