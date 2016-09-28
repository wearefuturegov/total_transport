class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_passenger!
  skip_before_action :authenticate_passenger!, if: :devise_controller?
  layout :layout_by_resource
  before_action :set_page_title
  before_action :set_top_sec

  helper_method :current_passenger
  def current_passenger
    if @current_passenger
      @current_passenger
    else
      find_current_passenger
    end
  end

  def set_current_passenger(passenger)
    @current_passenger = session[:current_passenger] = @passenger.id
  end

  def logout_current_passenger
    @current_passenger = session[:current_passenger] = nil
  end

  protected

  def layout_by_resource
    if devise_controller?
      "admin"
    else
      "application"
    end
  end

  def authenticate_passenger!
    if current_passenger
      true
    else
      redirect_to new_passenger_path
    end
  end

  def find_current_passenger
    if session[:current_passenger]
      @current_passenger = Passenger.find_by_id(session[:current_passenger])
    else
      if Rails.env.test? && cookies[:stub_user_id].present?
        @current_passenger = Passenger.find_by_id(cookies[:stub_user_id]) if cookies[:stub_user_id]
      else
        nil
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone_number, :team_id, :photo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone_number, :photo])
  end

  def after_sign_in_path_for(resource_or_scope)
    admin_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    admin_root_path
  end

  def set_page_title
    @page_title = "Pickup"
  end

  def set_top_sec
    @top_sec = false
  end
end
