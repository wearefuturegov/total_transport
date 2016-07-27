class Admin::JourneysController < AdminController
  before_filter :find_route
  before_filter :find_journey, only: [:edit, :update, :destroy]
  before_filter :check_permissions, except: [:index, :create]
  def index
    @journeys = @route.journeys
  end

  def create
    @route.journeys.create!(journey_params)
    redirect_to admin_route_journeys_path(@route)
  end

  def edit
  end

  def update
    @journey.update_attributes(journey_params)
    redirect_to admin_route_journeys_path(@route)
  end

  def destroy
    @journey.destroy
    redirect_to admin_route_journeys_path(@route)
  end

  private
  def find_route
    @route = Route.find(params[:route_id])
  end

  def journey_params
    params.require(:journey).permit(:start_time, :vehicle_id, :supplier_id)
  end

  def find_journey
    @journey = @route.journeys.find(params[:id])
  end

  def check_permissions
    unless @journey.editable_by_supplier?(current_supplier)
      render :file => "public/401.html", :status => :unauthorized
    end
  end
end
