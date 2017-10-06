class PlacesController < PublicController
  
  before_filter :get_places, only: [:index]
  before_filter :get_place, only: [:show]
  
  def index
    respond_to do |format|
      format.json do
        render json: @places.as_json
      end
    end
  end
  
  def show
    respond_to do |format|
      format.json do
        render json: @place.as_json
      end
    end
  end
  
  private
  
    def places_params
      params.permit(:origin, :query)
    end
    
    def get_places
      if places_params[:query]
        @places = PlacenamesService.new(places_params[:query]).search
      elsif places_params[:origin].blank?
        @places = Place.all
      else
        origin = places_params[:origin]
        routes = Place.friendly.find(origin).routes
        places = routes.map { |r| r.places }
        @places = places.flatten.reject { |p| p.slug == origin }
      end
    end
    
    def get_place
      @place = Place.find_by_os_id!(params[:id])
    end

end
