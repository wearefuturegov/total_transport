class Admin::BookingsController < AdminController
  before_filter :check_permissions
  
  def index
    filter = params[:filterrific] || {}
    @filter = initialize_filterrific(Booking.all, filter) or return
    bookings = @filter.find
    @bookings = bookings.page(params[:page])
    @bookings_count = bookings.count
    @passengers_count = bookings.inject(0) { |sum, p| sum + p.number_of_passengers }
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data csv_data(@bookings), filename: "bookings.csv", type: 'text/csv;charset=utf-8' }
    end
  end
  
  def show
    @booking = Booking.find(params[:id])
    @trip = params[:journey_id].to_i == @booking.journey.id ? @booking.outward_trip : @booking.return_trip
    @back_path = admin_journey_path(@booking.journey_id)
  end
  
  def update
    @booking = Booking.find(params[:id])
    @booking.update_attributes(booking_params)
    redirect_to admin_journey_path(@booking.journey)
  end
  
  def csv_data(bookings)
    CSV.generate do |csv|
      csv << Booking.csv_headers
      bookings.each do |booking|
        csv << booking.csv_row
      end
    end
  end
  
  private
  
    def booking_params
      params.require(:booking).permit(:state)
    end
  
end
