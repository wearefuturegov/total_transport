class PlacesController < PublicController
  
  def index
    places = places_params[:origin_id].present? ? get_destinations(places_params[:origin_id]) : Place.all
    respond_to do |format|
      format.json do
        render json: places.as_json
      end
    end
  end
  
  private
  
    def places_params
      params.permit(:origin_id)
    end
    
    def get_destinations(origin)
      routes = Place.find(origin).routes
      routes.map { |r| r.places }.flatten.reject { |p| p.id == origin }
    end

end
