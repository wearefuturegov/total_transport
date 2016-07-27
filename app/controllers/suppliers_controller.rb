class SuppliersController < ApplicationController
  before_action :authenticate_supplier!
end
