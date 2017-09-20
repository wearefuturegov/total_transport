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
      params.permit(:origin_id)
    end
    
    def get_places
      if places_params[:origin_id].blank?
        @places = Place.all
      else
        origin = places_params[:origin_id]
        routes = Place.find(origin).routes
        places = routes.map { |r| r.places }
        @places = places.flatten.reject { |p| p.id == origin }
      end
    end

end
