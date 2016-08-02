class Admin::VehiclesController < AdminController
  def index
    @vehicles = current_team.vehicles
  end
  def new
    @vehicle = current_team.vehicles.new
  end
  def create
    @vehicle = current_team.vehicles.new(vehicle_params)
    @vehicle.save
    redirect_to admin_vehicles_path
  end
  def edit
    @vehicle = current_team.vehicles.find(params[:id])
  end
  def update
    @vehicle = current_team.vehicles.find(params[:id])
    @vehicle.update_attributes(vehicle_params)
    redirect_to admin_vehicles_path
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(:seats, :registration, :make_model, :colour)
  end
end
