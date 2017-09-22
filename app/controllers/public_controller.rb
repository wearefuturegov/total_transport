class PublicController < ApplicationController
  layout 'application'
    
  before_action :set_page_title
  before_filter :create_body_id
  
  def index
  end

  helper_method :current_passenger
  def current_passenger
    @current_passenger ||= find_current_passenger
  end

  def set_current_passenger(passenger)
    session[:current_passenger] = passenger.session_token
  end

  protected
  
  def authenticate_passenger!
    current_passenger.nil? ? redirect_to(new_passenger_path) : true
  end
  
  def find_current_passenger
    session[:current_passenger] ? Passenger.find_by_session_token(session[:current_passenger]) : nil
  end

  def set_page_title
    @page_title = t('service')
  end

  def create_body_id
    @body_id = "#{params[:controller]}-#{params[:action]}"
  end

end
