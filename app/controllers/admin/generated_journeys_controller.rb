class Admin::GeneratedJourneysController < AdminController
  before_filter :get_journey, only: [:edit, :approve]

  def index
    @generated_journeys = current_team.generated_journeys
  end
  
  def edit
  end
  
  def approve
    vehicle = Vehicle.find(generated_journey_params[:vehicle_id])
    @generated_journey.approve(current_supplier, vehicle, {
      start_time: generated_journey_params[:start_time],
      open_to_bookings: generated_journey_params[:open_to_bookings]
    })
    redirect_to admin_root_path
  end
  
  private
  
    def get_journey
      @generated_journey = GeneratedJourney.find(params[:id])
    end
    
    def generated_journey_params
      params.require(:generated_journey).permit(:vehicle_id, :start_time, :open_to_bookings)
    end

end
