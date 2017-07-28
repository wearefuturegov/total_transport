require "rails_helper"

RSpec.describe SupplierMailer, type: :mailer do
  
  context 'journey_email' do
    let(:suppliers) { FactoryGirl.create_list(:supplier, 4) }
    let(:vehicles) { FactoryGirl.create_list(:vehicle, 2) }
    let(:route) {
      FactoryGirl.create(:route, stops: [
        FactoryGirl.create(:stop, name: 'First Stop'),
        FactoryGirl.create(:stop, name: 'Second Stop'),
        FactoryGirl.create(:stop, name: 'Last Stop')
      ])
    }
    let(:journey) { FactoryGirl.create(:generated_journey, route: route, start_time: DateTime.parse('2017-01-01T09:00:00')) }
    let(:mail) { described_class.journey_email(suppliers, journey, vehicles).deliver_now }
    
    it 'delivers to the right recipients' do
      expect(mail.to).to eq(suppliers.map(&:email))
    end
    
    it 'has the correct subject' do
      expect(mail.subject).to eq('A journey is available for approval')
    end
    
    it 'contains the correct information in the body' do
      expect(mail.body).to match /Last Stop \- First Stop/
      expect(mail.body).to match /Sunday  1 January/
      expect(mail.body).to match /9:00am/
    end
    
  end
  
end
