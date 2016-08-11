class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_passenger!
  skip_before_action :authenticate_passenger!, if: :devise_controller?

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
      nil
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone_number, :team_id, :photo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone_number, :photo])
  end
end
