class JourneysController < PublicController
  before_filter :find_places
  
  def index
    if @from && @to
      @journeys = Journey.available_for_places(@from, @to)
      @booking = Booking.new
    end
  end
  
  private
  
    def journey_params
      params.permit(:from, :to)
    end
    
    def find_places
      if journey_params[:from] && journey_params[:to]
        @from = Place.friendly.find(journey_params[:from])
        @to = Place.friendly.find(journey_params[:to])
      end
    end
  
end
