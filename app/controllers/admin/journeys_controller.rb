class Admin::JourneysController < AdminController
  before_filter :find_journey, only: [:edit, :update, :destroy, :show, :send_message]
  before_filter :check_permissions, except: [:index, :create, :new, :show, :surrounding_journeys]
  def index
    if params[:filter] == 'team'
      @journeys = current_team.journeys
    else
      @journeys = current_supplier.journeys
    end
  end

  def new
    @journey = current_supplier.journeys.new
    @back_path = admin_root_path
  end

  def create
    journey = Journey.create!(journey_params)
    redirect_to admin_journeys_path
  end

  def edit
    @back_path = admin_journey_path(@journey)
  end

  def show
    @back_path = admin_root_path
  end

  def update
    @journey.update_attributes(journey_params)
    redirect_to admin_journey_path(@journey)
  end

  def destroy
    @journey.destroy
    redirect_to admin_journeys_path
  end

  def surrounding_journeys
    @route = Route.find(params[:route_id])
    @previous_journeys = @route.journeys.where('start_time < ?', params[:datetime]).order('start_time DESC').limit(2)
    @next_journeys = @route.journeys.where('start_time > ?', params[:datetime]).order('start_time ASC').limit(2)
    render layout: false
  end

  def send_message
    if params[:to] == "all"
      @journey.bookings.each do |booking|
        booking.send_notification!(params[:notification_message])
      end
    else
      @journey.bookings.find(params[:to]).send_notification!(params[:notification_message])
    end
    flash[:notice] = "Message sent!"
    redirect_to admin_journey_path(@journey)
  end

  private

  def journey_params
    params.require(:journey).permit(:start_time, :vehicle_id, :supplier_id, :route_id, :open_to_bookings)
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
