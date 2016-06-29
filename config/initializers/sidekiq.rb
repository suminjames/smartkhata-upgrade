# https://makandracards.com/makandra/28125-perform-sidekiq-jobs-immediately-in-development
# Perform Sidekiq jobs immediately in development,
# so you don't have to run a separate process.
# You'll also benefit from code reloading.
# if Rails.env.development?
#   require 'sidekiq/testing'
#   Sidekiq::Testing.inline!
# end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/12' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/12' }
end