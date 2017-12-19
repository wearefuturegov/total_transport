class Admin::RoutesController < AdminController
  before_filter :check_permissions
  before_filter :get_route, only: [:show, :update, :sort, :destroy]
  
  def index
    @routes = Route.all
    @route = Route.new
    @back_path = admin_account_path
  end

  def create
    @route = Route.create!
    path = admin_route_path(@route)
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
    @route = Route.find(params[:id])
  end
  
end
