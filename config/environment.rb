# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Excerpted from : http://stackoverflow.com/questions/1789032/send-email-from-localhost
# Localhost mail testing
# ActionMailer::Base.smtp_settings = {
#     :address        => 'smtp.gmail.com',
#     :domain         => 'mail.google.com',
#     :port           => 587,
#     :user_name      => 'test.sarojk@gmail.com',
#     :password       => 'OOBGc53wqCe8',
#     :authentication => :plain,
#     :enable_starttls_auto => true
# }

ActionMailer::Base.smtp_settings = {
    :user_name => 'danphesarojk',
    :password => 'dzXEfJ033ZKU',
    :domain => 'danpheinfotech.com',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}
