class PlacesController < PublicController
  
  before_filter :get_places, only: [:index]
  
  def index
    respond_to do |format|
      format.json do
        render json: @places
      end
    end
  end
  
  private
  
    def places_params
      params.permit(:query)
    end
    
    def get_places
      @places = Place.all.includes(:routes).as_json(methods: :route_count)
    end

end
