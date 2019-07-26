source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.4'
gem 'sass-rails', '~> 5.0'
gem 'draper', '~> 1.3' #decorators for view logic implementations
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks', '2.5.3'
gem 'jbuilder', '~> 2.0'
gem 'jquery-hotkeys-rails', '~> 0.7.9.1'
gem 'kaminari' #Scope & Engine based, clean, powerful, customizable and sophisticated paginator
gem 'has_scope' #map incoming controller parameters to named scopes in your resources
gem 'filterrific' #Rails Engine plugin that makes it easy to filter, search, and sort your ActiveRecord lists
gem 'bootstrap-kaminari-views' #default inclusion of Kaminari theme compatible with Twitter Bootstrap 2.0 and Twitter Bootstrap 3.0
gem 'prawn' #pdf generator
gem 'prawn-table', '~> 0.2.2' #Provides table support for PrawnPDF.
gem 'sidekiq' #background processing for Ruby WHY??? WHEN???
gem 'sinatra', '>= 1.3.0', require: false #microframework for dealing with HTTP from the server side
gem 'apartment-sidekiq' #takes care of storing the current tenant that a job is enqueued within
gem 'scout_apm' #detailed Rails application performance monitoring
gem 'awesome_print' #prints Ruby objects in full color exposing their internal structure with proper indentation
gem 'bootstrap-sass'
gem 'devise'
gem 'devise_invitable' #adds support to Devise for sending invitations by email (it requires to be authenticated) and accept the invitation setting the password.
gem 'high_voltage' #Easily include static pages in your Rails app
gem 'pg'
gem 'pundit' #Minimal authorization through OO design and pure Ruby classes
gem 'sendgrid' #integration between ActionMailer and the SendGrid SMTP API
gem 'simple_form' #Forms made easy MAYBE?
gem 'smart_listing' #SmartListing helps creating AJAX-enabled lists of ActiveRecord collections or arrays with pagination, filtering, sorting and in-place editing.
gem 'virtus' #allows you to define attributes on classes, modules or class instances (DISCONTINUED)
gem 'ancestry' #allows the records of a Ruby on Rails ActiveRecord model to be organised as a tree structure
gem 'zip-zip' #simple adapter to let all your dependencies use RubyZip v1.0.0(The required RubyZip)
gem 'axlsx' #helping you generate beautiful Office Open XML Spreadsheet documents without having to understand the entire ECMA specification
gem 'audited', '~> 4.3' #logs all changes to your models
gem 'simplecov', :require => false, :group => :test #code coverage analysis tool
# Converts array that is returned during ActiveRecord pluck to hash
gem 'pluck_to_hash'
gem 'nepali_calendar'
gem 'jquery-turbolinks' #easy and fast way to improve user experience (DEPRECATED) MAKES FASTER BUT HOW?
gem 'roo', '~> 2.1.0' #implements read access for all common spreadsheet types
gem 'roo-xls' #extends Roo to add support for handling class Excel files
gem 'mechanize', '2.7.3' #makes automated web interaction easy.
gem 'haml' #templating engine for HTML
gem 'haml-rails' #provides Haml generators for Rails
gem 'sankhya' #convert number to words in Devanagari Numbering System.
gem 'apartment' # Database Multitenancy for Rails
gem 'react-rails' # flexible tool to use React with Rails
gem 'slim'
gem 'whenever', :require => false # provides a clear syntax for writing and deploying cron jobs
gem 'exception_notification' #provides a set of notifiers for sending notifications when errors occur

group :production do
  gem 'puma', '~> 4.0.0'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'brakeman', :require => false #static analysis security vulnerability scanner for Ruby on Rails applications
  gem 'traceroute' #task gem that helps you find the unused routes and controller actions
  gem 'rack-mini-profiler' #displays speed badge for every html page
  gem 'better_errors' #replaces the standard Rails error page with a much better and more useful error page
  gem 'annotate' #Annotate Rails classes with schema and routes info
  gem 'hirb' # framework for console applications and uses it to  improve  irb's default inspect output
  gem 'capistrano', '~> 3.1' #framework for building automated deployment scripts
  gem 'capistrano-bundler' #In order for Bundler to work efficiently on the server
  gem 'capistrano-rails', '~> 1.1.0' #Rails specific tasks for Capistrano
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'quiet_assets' #turns off the Rails asset pipeline log (DEPRECATED)
  gem 'rails_layout' #Generates Rails application layout files for various front-end frameworks.
  gem 'bullet' #kills N+1 queries and unused eager loading
  gem 'uniform_notifier' #ability to send notification through rails logger, customized logger, javascript alert, javascript console, growl, xmpp, airbrake and honeybadger.
  gem 'capistrano3-puma' #Puma integration for Capistrano
  gem 'rails_best_practices' #code metric tool to check the quality of Rails code.
  gem 'rails-erd' # Generate Entity-Relationship Diagrams

  gem 'guard' #automates various tasks by running custom rules whenever file or directories are modified.
  gem 'guard-rspec', require: false
  gem 'spring-commands-rspec'
  gem 'guard-minitest', '~> 2.4', '>= 2.4.4'
  gem 'pry-stack_explorer'
end

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'minitest-reporters', '~> 1.1', '>= 1.1.8'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem "database_cleaner"
#  gem "poltergeist"
  gem "shoulda-matchers"
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'mocha'
  gem "webmock"
  gem "vcr"
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 4.0'
end
