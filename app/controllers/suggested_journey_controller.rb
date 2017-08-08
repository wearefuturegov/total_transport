class SuggestedJourneyController < PublicController
  
  before_filter :find_route_and_booking
  
  def new
    @page_title = "Suggest A New Time"
    @suggested_journey = SuggestedJourney.new
  end
  
  def create
    @suggested_journey = @booking.create_suggested_journey(suggested_journey_params)
    redirect_to @back_path
  end
  
  private
  
    def suggested_journey_params
      params.require(:suggested_journey).permit(:start_time, :description).merge(route: @route, passenger: current_passenger)
    end
    
    def find_route_and_booking
      @route = Route.find(params[:route_id])
      @booking = current_passenger.bookings.find(params[:id])
      @back_path = edit_journey_route_booking_path(@route, @booking)
    end

end
