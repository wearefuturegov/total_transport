class PlacesController < PublicController
  
  before_filter :get_places, only: [:index]
  
  def index
    respond_to do |format|
      format.json do
        render json: @places.as_json
      end
    end
  end
  
  private
  
    def places_params
      params.permit(:origin)
    end
    
    def get_places
      if places_params[:origin].blank?
        @places = Place.all
      else
        origin = places_params[:origin]
        routes = Place.friendly.find(origin).routes
        places = routes.map { |r| r.places }
        @places = places.flatten.reject { |p| p.slug == origin }
      end
    end

end
