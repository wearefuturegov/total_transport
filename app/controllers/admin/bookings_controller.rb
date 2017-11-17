class Admin::BookingsController < AdminController
  before_filter :check_permissions
  
  def show
    @booking = Booking.find(params[:id])
    @trip = params[:journey_id].to_i == @booking.journey.id ? @booking.outward_trip : @booking.return_trip
    @back_path = admin_journey_path(@booking.journey_id)
  end
  
end
