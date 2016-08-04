class AdminController < ApplicationController
  skip_before_action :authenticate_passenger!
  before_action :authenticate_supplier!
  layout 'admin'
  helper_method :current_team
  def current_team
    current_supplier.team
  end
end
