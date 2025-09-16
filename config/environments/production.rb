# config/environments/production.rb

Rails.application.configure do
  # Ensure secret_key_base is set, fallback to a dummy for asset precompilation or non-prod tasks
  config.secret_key_base = ENV['SECRET_KEY_BASE'] || 'dummy_secret_for_assets'

  # Code is eagerly loaded for better performance in production
  config.eager_load = true

  # Disable full error reports
  config.consider_all_requests_local = false

  # Enable caching
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }

  # Serve static files and cache them long-term
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Force SSL unless explicitly disabled
  config.force_ssl = ENV['DISABLE_SSL'].blank?

  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]

  # Active Storage configuration
  config.active_storage.service = :local

  # Active Job adapter
  config.active_job.queue_adapter = :resque

  # I18n fallback
  config.i18n.fallbacks = true

  # Do not dump schema after migrations
  config.active_record.dump_schema_after_migration = false
end
