require 'webmock/rspec'

def get_fixture(filename)
  File.open(File.join 'spec', 'fixtures', filename).read
end

RSpec.configure do |config|
  
  config.before(:all) do
    WebMock.disable!
  end
  
  config.before(:all, webmock: true) do
    WebMock.enable!
  end
  
end
