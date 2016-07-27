class Suppliers::VehiclesController < SuppliersController
  def index
    @vehicles = current_user.team.vehicles
  end
  def new
    @vehicle = current_user.team.vehicles.new
  end
  def create
    @vehicle = current_user.team.vehicles.new(vehicle_params)
    @vehicle.save
    redirect_to suppliers_vehicles_path
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(:seats, :registration, :make_model, :colour)
  end
end
