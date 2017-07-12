class AdminController < ApplicationController
  layout 'admin'
  
  before_action :authenticate_supplier!, :create_body_id
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  helper_method :current_team
  
  def current_team
    current_supplier.team
  end
  
  protected
  
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
  
  def create_body_id
    @body_id = "#{params[:controller]}-#{params[:action]}"
  end

  private

  def check_permissions
    unless current_supplier.admin?
      render :file => "public/401.html", :status => :unauthorized
    end
  end
end
