class Admin::VehiclesController < AdminController
  def index
    @vehicles = current_supplier.team.vehicles
  end
  def new
    @vehicle = current_supplier.team.vehicles.new
  end
  def create
    @vehicle = current_supplier.team.vehicles.new(vehicle_params)
    @vehicle.save
    redirect_to admin_vehicles_path
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(:seats, :registration, :make_model, :colour)
  end
end
