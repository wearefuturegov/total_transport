class Admin::StopsController < AdminController
  before_action :find_route
  before_action :get_places, only: [:new, :edit, :create]
  
  def new
    @stop = @route.stops.new
    @back_path = admin_route_path(@route)
  end

  def create
    @stop = @route.stops.new(stop_params)
    
    if @stop.save
      if params[:commit] == "Create & add another stop"
        redirect_to new_admin_route_stop_path(@route)
      else
        redirect_to admin_route_path(@route)
      end
    else
      flash[:alert] = @stop.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @stop = @route.stops.find(params[:id])
    @back_path = admin_route_path(@route)
  end

  def update
    @stop = @route.stops.find(params[:id])
    @stop.update_attributes(stop_params)
    if @stop.valid?
      redirect_to admin_route_path(@route)
    else
      flash[:alert] = @stop.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @stop = @route.stops.find(params[:id])
    @stop.destroy
    redirect_to admin_route_path(@route)
  end


  private

  def stop_params
    params.require(:stop).permit(
      :place_id, :minutes_from_last_stop,
      landmarks_attributes: [:id, :name, :latitude, :longitude, :_destroy]
    )
  end

  def find_route
    @route = Route.find(params[:route_id])
  end
  
  def get_places
    @places = Place.all
  end
end
