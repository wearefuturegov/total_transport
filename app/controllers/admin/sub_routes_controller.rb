class Admin::SubRoutesController < AdminController
  before_filter :check_permissions
  before_filter :get_route, only: [:show, :update, :sort, :destroy]
  
  def index
    @routes = Route.where(route_id: params[:route_id])
    @route = Route.new
    @back_path = admin_route_path(params[:route_id])
    @new_route_path = admin_route_sub_routes_path(params[:route_id])
    render 'admin/routes/index'
  end

  def create
    @route = Route.copy!(params[:route_id])
    redirect_to admin_route_sub_route_path(params[:route_id], @route)
  end

  def show
    @back_path = admin_route_path(params[:route_id])
    render 'admin/routes/show'
  end
  
  def destroy
    @route.destroy
    redirect_to admin_routes_path
  end
  
  private
  
  def get_route
    @route = Route.find_by(id: params[:id], route_id: params[:route_id])
  end
  
end
