class Admin::PlacesController < AdminController
  
  before_action :get_back_path, :set_defaults

  def new
  end
  
  def create
    place = Place.create(place_params)
    if place.valid?
      redirect_to @back_path
    else
      flash[:error] = place.errors.to_a.join('<br/>')
      render :new
    end
  end
  
  private
  
    def place_params
      params.require(:place).permit(:name, :latitude, :longitude)
    end
    
    def get_back_path
      @back_path = if params[:previous_route_id]
        new_admin_route_stop_path(params[:previous_route_id])
      else
        admin_account_path
      end
    end
    
    def set_defaults
      @place = Place.new
      @route_id = params[:previous_route_id]
    end

end
