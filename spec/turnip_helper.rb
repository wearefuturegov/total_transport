require 'turnip/capybara'
require 'selenium/webdriver'
require 'rails_helper'

require 'support/wait_for_ajax'
require 'support/turnip_formatter'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  # capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  #   chromeOptions: { args: %w(headless disable-gpu) }
  # )

  Capybara::Selenium::Driver.new app,
    browser: :chrome#,
    #desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

Dir.glob("spec/features/steps/**/*steps.rb") { |f| load f, true }
