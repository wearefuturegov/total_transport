class Admin::RoutesController < AdminController
  before_filter :check_permissions
  def create
    route = Route.create!
    redirect_to admin_route_path(route)
  end
  def show
    @route = Route.find(params[:id])
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

  private

  def check_permissions
    unless current_supplier.admin?
      render :file => "public/401.html", :status => :unauthorized
    end
  end
end
