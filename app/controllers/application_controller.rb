class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :redirect_to_closure_notice

  def redirect_to_closure_notice
    redirect_to closure_notice_path
  end
end
