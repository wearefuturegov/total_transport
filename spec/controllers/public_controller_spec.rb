require 'rails_helper'

RSpec.describe PublicController, type: :controller do

  describe '#index' do
    
    let(:subject) {
      get :index
    }
    
    it 'renders the homepage by default' do
      expect(subject).to render_template('application/index')
    end
    
    it 'renders the demo if the demo env var is set' do
      stub_const('ENV', ENV.to_hash.merge('DEMO' => '1'))
      expect(subject).to render_template('application/demo')
    end
    
  end


  
end
