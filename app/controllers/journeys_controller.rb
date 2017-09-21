class JourneysController < PublicController
  
  def index
    if journey_params[:from_id] && journey_params[:to_id]
      @journeys = Journey.available_for_places(journey_params[:from_id], journey_params[:to_id])
      @booking = Booking.new
    end
  end
  
  private
  
    def journey_params
      params.permit(:from_id, :to_id)
    end
  
end
