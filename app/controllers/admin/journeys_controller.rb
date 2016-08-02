class Admin::JourneysController < AdminController
  before_filter :find_journey, only: [:edit, :update, :destroy, :show]
  before_filter :check_permissions, except: [:index, :create, :new]
  def index
    @journeys = Journey.all
  end

  def create
    journey = Journey.create!(journey_params)
    redirect_to admin_journey_path(journey)
  end

  def edit
  end

  def update
    @journey.update_attributes(journey_params)
    redirect_to admin_journey_path(@journey)
  end

  def destroy
    @journey.destroy
    redirect_to admin_journeys_path
  end

  def journey_params
    params.require(:journey).permit(:start_time, :vehicle_id, :supplier_id)
  end

  def find_journey
    @journey = Journey.find(params[:id])
  end

  def check_permissions
    unless @journey.editable_by_supplier?(current_supplier)
      render :file => "public/401.html", :status => :unauthorized
    end
  end
end
