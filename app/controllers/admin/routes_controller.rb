class Admin::RoutesController < AdminController
  before_filter :check_permissions
  before_filter :get_route, only: [:show, :update, :sort, :destroy]
  
  def index
    @routes = params[:route_id].nil? ? Route.all : Route.where(route_id: params[:route_id])
    @route = Route.new
    @back_path = admin_account_path
  end

  def create
    @route = params[:route_id].nil? ? Route.create! : Route.create!(route_id: params[:route_id])
    redirect_to admin_route_path(@route)
  end

  def show
    @back_path = admin_routes_path
  end
  
  def destroy
    @route.destroy
    redirect_to admin_routes_path
  end
  
  def sort
    params[:stop].each_with_index do |value,index|
      @route.stops.find(value).update_attribute(:position,index+1)
    end
    render :nothing => true
  end
  
  private
  
  def get_route
    @route = params[:route_id].nil? ? Route.find(params[:id]) : Route.find_by(id: params[:id], route_id: params[:route_id])
  end
  
end
