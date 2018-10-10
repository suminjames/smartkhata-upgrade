# require 'selenium-webdriver'
# Capybara.asset_host = 'http://localhost:3000'

# Capybara.register_driver :chrome do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    # chromeOptions: { args: %w[headless disable-gpu window-size=1366,768] }
    chromeOptions: { args: %w[headless disable-gpu window-size=1366,768] }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

# Capybara.default_driver = :chrome
Capybara.javascript_driver = :headless_chrome
