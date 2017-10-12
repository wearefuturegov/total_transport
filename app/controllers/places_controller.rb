class PlacesController < PublicController
  
  before_filter :get_places, only: [:index]
  before_filter :get_place, only: [:show]
  
  rescue_from ActiveRecord::RecordNotFound do
    if params[:origin]
      TrackFailedPlaceQuery.enqueue(params[:origin], params[:name], DateTime.now.to_s)
    elsif params[:name]
      TrackFailedPlaceQuery.enqueue(params[:name], nil, DateTime.now.to_s)
    end
    head 404, "content_type" => 'text/plain'
  end
  
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
    
    def get_place
      @place = Place.find_by_os_id!(params[:id])
    end

end
