ruby '2.3.4'
source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7.1'
# Use postgresql as the database for Active Record
gem 'pg', '= 0.21.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.3.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# include bourbon/neat/bitters for basic template
gem 'bourbon'
# refer to older documentation http://neat.bourbon.io/docs/1.7.1/
gem 'neat', '< 2.0'
gem 'bitters'
# Haml is the way
gem 'haml-rails', '~> 1.0'
# Fontawesome is pretty awesome
gem "font-awesome-rails"
# other starter gems
gem 'high_voltage'
gem 'normalize-rails'
gem 'font-awesome-sass', '~> 4.7.0'
gem 'jquery-ui-rails', '>= 5.0.5', '< 6.0.0'

gem 'geokit'

gem 'acts_as_list', '>= 0.9.5'

gem 'devise', '>= 4.3.0'

gem 'rails_12factor'
gem 'puma'
gem 'dotenv-rails', '>= 2.2.1', :groups => [:development, :test]

gem 'airbrake', '~> 4.1'

gem 'twilio-ruby'

gem 'paperclip'
gem 'aws-sdk', '~> 2.3'

gem 'filterrific'
gem 'kaminari', '>= 1.0.1'
gem 'que'
gem 'platform-api'
gem 'friendly_id'
gem 'google_drive'
gem 'cocoon'
gem 'postcodes_io'
gem 'stripe'
gem 'polylines'

gem 'leaflet-rails'

# Require FactoryBot in production for seeding purposes
gem 'factory_bot_rails', '>= 4.8.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'
  gem 'rspec-rails', '~> 3.5.2'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'webmock'
  gem 'simplecov'
  gem 'timecop'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'capybara-selenium'
  gem 'chromedriver-helper'
  gem 'brakeman', require: false
  gem 'coveralls', require: false
  gem 'turnip'
  gem 'vcr'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.3'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'stripe-ruby-mock', '~> 2.5.3', :require => 'stripe_mock'
end

source 'https://rails-assets.org' do
  gem 'rails-assets-datetimepicker'
  gem 'rails-assets-jquery', '~> 1.12'
end
