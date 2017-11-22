class JourneysController < PublicController
  before_filter :find_places
  respond_to :html, :js
  
  def index
    if @from && @to
      @journeys = Journey.available_for_places(@from, @to)
      if @to.routes.count == 0 || @journeys.count == 0
        @possible_destinations = Place.possible_destinations(@from)
        TrackFailedPlaceQuery.enqueue(@from.name, @to.name, DateTime.now.to_s)
      end
    end
  end
  
  def return
    start_time = DateTime.parse params[:start_time]
    @booking = Booking.new
    available_journeys = Journey.available_for_places(@to, @from)
    @journeys = Journey.where(id: available_journeys).where(
      start_time: start_time...start_time.end_of_day
    )
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
