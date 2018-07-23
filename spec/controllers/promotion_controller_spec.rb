require 'rails_helper'

RSpec.describe PromotionController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to be_successful
    end
  end

end
