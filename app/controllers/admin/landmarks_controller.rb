class Admin::LandmarksController < AdminController
  before_filter :find_route_and_stop, :set_back_path
  before_filter :find_landmark, only: [:edit, :update, :destroy]

  def index
    @landmarks = @stop.landmarks
  end

  def new
    @landmark = @stop.landmarks.new
  end

  def create
    @landmark = @stop.landmarks.create!(landmark_params)
    redirect_to @back_path
  end

  def edit
    @back_path = admin_route_stop_landmarks_path(@route, @stop)
  end

  def update
    @landmark.update_attributes!(landmark_params)
    redirect_to @back_path
  end

  def destroy
    @landmark.destroy
    redirect_to @back_path
  end

  private
  
  def find_route_and_stop
    @route = Route.find(params[:route_id])
    @stop = @route.stops.find(params[:stop_id])
  end
  
  def set_back_path
    @back_path = admin_route_stop_landmarks_path(@route, @stop)
  end
  
  def find_landmark
    @landmark = @stop.landmarks.find(params[:id])
  end
  
  def landmark_params
    params.require(:landmark).permit(:name, :latitude, :longitude)
  end
end
