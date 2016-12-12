class Admin::BookingsController < AdminController
  before_filter :check_permissions
  
  def show
    @booking = Booking.find(params[:id])   
    @back_path = admin_journey_path(@booking.journey_id)
  end
  
end
