Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.reload_classes_only_on_change = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  # config.log_level = :error
  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # IMPORTANT! The following is set to true by default. Setting it to false makes page loading faster but has its own (apparently trivial to this project) complexities. See for more: http://stackoverflow.com/questions/16357785/what-exactly-config-assets-debug-setting-does Also see: http://artandlogic.com/2012/12/faster-rails-dev/
  config.assets.debug = false

  config.action_mailer.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: 587,
    domain: Rails.application.secrets.domain_name,
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: Rails.application.secrets.email_provider_username,
    password: Rails.application.secrets.email_provider_password
  }

  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  # Send email in development mode?
  config.action_mailer.perform_deliveries = true


  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  # config.force_ssl = false
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Bullet gem's config excerpted from https://github.com/flyerhzm/bullet
  config.after_initialize do
    Bullet.enable = true
    # TODO Turn it back to on to get javascript alerts
    Bullet.alert = false
    Bullet.bullet_logger = true
    Bullet.console = true
    # Bullet.growl = true
    # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #   :password => 'bullets_password_for_jabber',
    #   :receiver => 'your_account@jabber.org',
    #   :show_online_status => true }
      Bullet.rails_logger = true
      # Bullet.honeybadger = true
      # Bullet.bugsnag = true
      # Bullet.airbrake = true
      # Bullet.rollbar = true
      Bullet.add_footer = true
      Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
      Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
      # Bullet.slack = { webhook_url: 'http://some.slack.url', foo: 'bar' }
    end
end
