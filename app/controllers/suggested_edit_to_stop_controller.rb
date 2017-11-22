class SuggestedEditToStopController < PublicController
  
  before_filter :find_route_stop_and_booking
  
  def new
    @page_title = "Suggest A Stop Area Edit"
    @suggested_edit_to_stop = SuggestedEditToStop.new
  end
  
  def create
    @suggested_edit_to_stop = SuggestedEditToStop.create!(suggested_edit_to_stop_params)
    redirect_to @back_path
  end
  
  private
  
    def suggested_edit_to_stop_params
      params.require(:suggested_edit_to_stop).permit(:description).merge(stop: @stop, passenger: current_passenger)
    end
    
    def find_route_stop_and_booking
      @route = Route.find(params[:route_id])
      @booking = current_passenger.bookings.find(params[:id])
      @stop = Stop.find(params[:stop_id])
      @back_path = edit_booking_path(@booking)
    end
  
end
