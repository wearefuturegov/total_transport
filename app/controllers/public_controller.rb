class PublicController < ApplicationController
  layout 'application'
    
  before_action :set_page_title
  before_action :create_body_id
  
  def index
    template = ENV['DEMO'] ? 'application/demo' : 'application/index'
    render template
  end

  protected

  def set_page_title
    @page_title = t('service')
  end

  def create_body_id
    @body_id = "#{params[:controller]}-#{params[:action]}"
  end

end
