class UnsubscribedController < ApplicationController
  
  before_action :set_page_title
  before_action :create_body_id

  def index
  end

  def set_page_title
    @page_title = t('service')
  end

  def create_body_id
    @body_id = "#{params[:controller]}-#{params[:action]}"
  end

end
