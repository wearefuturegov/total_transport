class PlacesController < PublicController
  
  before_filter :get_places, only: [:index]
  
  def index
    respond_to do |format|
      format.json do
        render json: @places.as_json(include: :routes)
      end
    end
  end
  
  private
  
    def places_params
      params.permit(:query)
    end
    
    def get_places
      @places = places_params[:query].nil? ? Place.all : Place.where("name ILIKE ?", "#{places_params[:query]}%")
    end

end
