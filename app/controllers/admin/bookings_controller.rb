class Admin::BookingsController < AdminController
  before_filter :check_permissions
  
  def index
    filter = params[:filterrific] || {}
    @filter = initialize_filterrific(Booking.all, filter)
    @bookings = @filter.find.page(params[:page])
    respond_to do |format|
      format.html
      format.csv { send_data csv_data(@bookings), filename: "bookings.csv", type: 'text/csv;charset=utf-8' }
    end
  end
  
  def show
    @booking = Booking.find(params[:id])
    @trip = params[:journey_id].to_i == @booking.journey.id ? @booking.outward_trip : @booking.return_trip
    @back_path = admin_journey_path(@booking.journey_id)
  end
  
  def csv_data(bookings)
    CSV.generate do |csv|
      csv << [
        'Name',
        'Phone Number',
        'Pickup Place',
        'Dropoff Place',
        'Pickup Landmark',
        'Dropoff Landmark',
        'Pickup Time',
        'Dropoff Time',
        'Price'
      ]
      bookings.each do |booking|
        csv << booking.csv_row
      end
    end
  end
  
end
