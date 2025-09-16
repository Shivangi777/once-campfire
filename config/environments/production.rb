# config/environments/production.rb

Rails.application.configure do
  # -----------------------
  # Secret Key Base
  # -----------------------
  # Use ENV['SECRET_KEY_BASE'] at runtime, fallback to dummy during assets precompile
  config.secret_key_base = ENV['SECRET_KEY_BASE'] || 'dummy_secret_for_assets'

  # -----------------------
  # Code Loading
  # -----------------------
  config.eager_load = true
  config.cache_classes = true
  config.consider_all_requests_local = false

  # -----------------------
  # Caching
  # -----------------------
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error "Redis error: #{exception}"
    }
  }

  # -----------------------
  # Assets
  # -----------------------
  config.public_file_server.enabled = true
  config.assets.compile = false
  config.assets.digest = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # -----------------------
  # SSL
  # -----------------------
  config.force_ssl = ENV['DISABLE_SSL'].blank?

  # -----------------------
  # Logging
  # -----------------------
  config.log_level = :info
  config.logger = ActiveSupport::Logger.new(STDOUT)
  config.log_tags = [:request_id]

  # -----------------------
  # Active Storage
  # -----------------------
  config.active_storage.service = :local

  # -----------------------
  # Active Job
  # -----------------------
  config.active_job.queue_adapter = :resque

  # -----------------------
  # I18n
  # -----------------------
  config.i18n.fallbacks = true

  # -----------------------
  # Database
  # -----------------------
  config.active_record.dump_schema_after_migration = false
end
