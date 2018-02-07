class Admin::RoutesController < AdminController
  before_filter :check_permissions
  before_filter :get_route, only: [:show, :update, :sort, :destroy]
  before_filter :get_pricing_rules, only: [:show]
  
  def index
    @routes = Route.where(route: nil)
    @route = Route.new
    @back_path = admin_account_path
    @new_route_path = admin_routes_path
  end

  def create
    @route = Route.create!
    path = admin_route_path(@route)
    redirect_to admin_route_path(@route)
  end

  def show
    @back_path = admin_routes_path
    @time_id = params[:time_id]
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def destroy
    @route.destroy
    redirect_to admin_routes_path
  end
  
  def update
    @route.update_attributes(route_params)
    @route.save
    redirect_to admin_route_path(@route)
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
  
  def route_params
    params.require(:route).permit(:name, :pricing_rule_id)
  end
  
  def get_pricing_rules
    @pricing_rules = PricingRule.all
  end
  
end
