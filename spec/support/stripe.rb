RSpec.configure do |config|

  config.before(:all, stripe: true) do
    @stripe_helper = StripeMock.create_test_helper
    StripeMock.start
  end
  
  config.after(:all, stripe: true) do
    StripeMock.stop
  end

end
