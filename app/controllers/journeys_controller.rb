class JourneysController < PublicController
  before_filter :find_places
  respond_to :html, :js
  
  def index
    if @from && @to
      @journeys = Journey.available_for_places(@from, @to)
      @booking = Booking.new
    end
  end
  
  def suggested
    @placename = params[:placename]
    routes = @from.routes
    places = routes.map { |r| r.places }
    @places = places.flatten.reject { |p| p.slug == @from.slug }
  end
  
  private
  
    def journey_params
      params.permit(:from, :to)
    end
    
    def find_places
      @from = Place.friendly.find(journey_params[:from]) if journey_params[:from]
      @to = Place.friendly.find(journey_params[:to]) if journey_params[:to]
    end
  
end
