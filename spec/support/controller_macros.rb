module ControllerMacros
  def login_supplier
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:supplier]
      @supplier = FactoryGirl.create(:supplier, admin: true, approved: true)
      sign_in @supplier
    end
  end
end
