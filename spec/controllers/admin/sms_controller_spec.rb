require 'rails_helper'

RSpec.describe Admin::SmsController, type: :controller do
  login_supplier(true)
  
  describe 'new' do
    subject { get :new }
    
    it 'renders the correct template' do
      expect(subject).to render_template('admin/sms/new')
    end
  end
  
  describe 'create' do
    let(:params) {
      {
        sms: {
          to: '+15005550006',
          body: 'Hello there'
        }
      }
    }
    subject { post :create, params }

    it 'sends an sms' do
      expect {
        subject
      }.to change { FakeSMS.messages.count }.by(1)
      
      expect(FakeSMS.messages.last[:to]).to eq(params[:sms][:to])
      expect(FakeSMS.messages.last[:body]).to eq(params[:sms][:body])
    end
    
    context 'with invalid phone number' do
      let(:params) {
        {
          sms: {
            to: '3232323232',
            body: 'Hello there'
          }
        }
      }
      
      it 'shows an error' do
        expect(subject).to render_template('admin/sms/new')
        expect(assigns(:flash_alert)).to eq('Phone number is not valid, please try another one')
      end
    end
  end
end
