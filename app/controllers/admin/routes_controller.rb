class Admin::RoutesController < AdminController
  before_filter :check_permissions
  
  def index
    @routes = Route.all
    @route = Route.new
    @back_path = admin_account_path
  end

  def create
    route = Route.create!
    redirect_to admin_route_path(route)
  end

  def show
    @route = Route.find(params[:id])
    @back_path = admin_routes_path
  end
  
  def destroy
    @route = Route.find(params[:id])
    @route.destroy
    redirect_to admin_routes_path
  end
  
  def sort
    @route = Route.find(params[:id])
    params[:stop].each_with_index do |value,index|
      @route.stops.find(value).update_attribute(:position,index+1)
    end
    render :nothing => true
  end
  
end
