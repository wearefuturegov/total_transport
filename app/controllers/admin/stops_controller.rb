class Admin::StopsController < AdminController
  before_filter :find_route
  before_filter :get_places, only: [:new, :edit]
  def new
    @stop = @route.stops.new
    @back_path = admin_route_path(@route)
  end

  def create
    @stop = @route.stops.new(stop_params)
    @stop.save
    if params[:commit] == "Create & add another stop"
      redirect_to new_admin_route_stop_path(@route)
    else
      redirect_to admin_route_path(@route)
    end
  end

  def edit
    @stop = @route.stops.find(params[:id])
    @back_path = admin_route_path(@route)
  end

  def update
    @stop = @route.stops.find(params[:id])
    @stop.update_attributes(stop_params)
    redirect_to admin_route_path(@route)
  end

  def destroy
    @stop = @route.stops.find(params[:id])
    @stop.destroy
    redirect_to admin_route_path(@route)
  end


  private

  def stop_params
    params.require(:stop).permit(:place_id, :minutes_from_last_stop)
  end

  def find_route
    @route = Route.find(params[:route_id])
  end
  
  def get_places
    @places = Place.all
  end
end
