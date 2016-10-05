class Admin::LandmarksController < AdminController
  before_filter :find_route
  before_filter :find_stop

  def index
    @landmarks = @stop.landmarks
  end

  def new
    @landmark = @stop.landmarks.new
  end

  def create
    @landmark = @stop.landmarks.create!(landmark_params)
    redirect_to admin_route_stop_landmarks_path(@route, @stop)
  end

  def edit
    @landmark = @stop.landmarks.find(params[:id])
  end

  def update
    @landmark = @stop.landmarks.find(params[:id])
    @landmark.update_attributes!(landmark_params)
    redirect_to admin_route_stop_landmarks_path(@route, @stop)
  end

  def destroy
    @landmark = @stop.landmarks.find(params[:id])
    @landmark.destroy
    redirect_to admin_route_stop_landmarks_path(@route, @stop)
  end

  private
  def find_route
    @route = Route.find(params[:route_id])
  end
  def find_stop
    @stop = @route.stops.find(params[:stop_id])
  end
  def landmark_params
    params.require(:landmark).permit(:name, :latitude, :longitude)
  end
end
