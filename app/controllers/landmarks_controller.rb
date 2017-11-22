class LandmarksController < PublicController

  def index
    @type = params[:type] == 'pickup' ? :pickup_landmark_id : :dropoff_landmark_id
    @selector =  params[:type] == 'pickup' ? '.pickup_landmarks' : '.dropoff_landmarks'
    @booking = Booking.new
    @landmarks = Landmark.where(stop: params[:stop_id])
  end

end
