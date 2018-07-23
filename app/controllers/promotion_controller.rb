class PromotionController < ApplicationController
  layout 'application'
  
  before_action :create_body_id

  def index
  end

  def create_body_id
    @body_id = "#{params[:controller]}-#{params[:action]}"
  end
end
