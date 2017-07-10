# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'devise'
require 'que/testing'

require 'support/fake_sms'
require 'support/controller_macros'

SmsService.client = FakeSMS

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.before :each do
    FakeSMS.messages = []
    SendSMS.jobs.clear
  end
  
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true
  
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
end
