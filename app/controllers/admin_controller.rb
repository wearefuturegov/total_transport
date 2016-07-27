class AdminController < ApplicationController
  before_action :authenticate_supplier!
  layout 'admin'
end
