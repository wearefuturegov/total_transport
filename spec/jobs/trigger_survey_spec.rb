require 'rails_helper'
require 'support/vcr'

RSpec.describe TriggerSurvey, :vcr, :webmock do
  
  before(:all) { Passenger.skip_callback(:save, :before, :format_phone_number) }
  after(:all) { Passenger.set_callback(:save, :before, :format_phone_number, if: :phone_number_changed?) }

  let(:booking) { FactoryBot.create(:booking, phone_number: '+15005550006') }
  let(:client) { Twilio::REST::Client.new }
  
  it 'triggers a survey' do
    expect { TriggerSurvey.run(booking: booking.id) }.to change {
      client.studio.v1.flows(ENV['TWILIO_FLOW_ID']).engagements.list.count
    }.by(1)
  end
  
  it 'sets survey_sent' do
    TriggerSurvey.run(booking: booking.id)
    booking.reload
    expect(booking.survey_sent).to eq(true)
  end
  
  it 'does not trigger if survey_sent is true' do
    booking.survey_sent = true
    booking.save
    expect { TriggerSurvey.run(booking: booking.id) }.to change {
      client.studio.v1.flows(ENV['TWILIO_FLOW_ID']).engagements.list.count
    }.by(0)
  end
  
  it 'deletes itself if the booking does not exist' do
    booking.delete
    expect_any_instance_of(TriggerSurvey).to receive(:destroy)
    TriggerSurvey.run(booking: booking.id)
  end

end
