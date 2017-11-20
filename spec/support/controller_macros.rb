module ControllerMacros
  def login_supplier(admin = false)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:supplier]
      @supplier = FactoryBot.create(:supplier, admin: admin, approved: true)
      sign_in @supplier
    end
  end
end
