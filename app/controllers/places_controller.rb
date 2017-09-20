class PlacesController < PublicController
  
  def index
    query = "#{places_params[:query]}%"
    places = if places_params[:origin_id].present?
      get_destinations(places_params[:origin_id], query)
    else
      Place.where('name ILIKE ?', query)
    end
    
    respond_to do |format|
      format.json do
        render json: places.as_json
      end
    end
  end
  
  private
  
    def places_params
      params.permit(:origin_id, :query)
    end
    
    def get_destinations(origin, query)
      routes = Place.find(origin).routes
      places = routes.map { |r| r.places.where('name ILIKE ?', query) }
      places.flatten.reject { |p| p.id == origin }
    end

end
