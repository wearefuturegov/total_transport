require 'rails_helper'

RSpec.describe JourneysController, type: :controller do
  
  it 'renders a template' do
    expect(get :index).to render_template(:index)
  end
  
end
