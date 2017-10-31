class Admin::JourneysController < AdminController
  before_filter :find_journey, only: [:edit, :update, :destroy, :show, :send_message]
  before_filter :check_permissions, except: [:index, :create, :new, :show, :surrounding_journeys]
  def index
    params[:filterrific] ||= {}
    journeys = params[:filter] == 'team' ? current_team.journeys : current_supplier.journeys
    @filterrific = initialize_filterrific(
      journeys,
      params[:filterrific]
    ) or return
    @journeys = @filterrific.find.page(params[:page])
  end

  def new
    if params[:route_id]
      @route = Route.find(params[:route_id])
      @journey = current_supplier.journeys.new(route: @route, reversed: params[:reversed])
      @back_path = new_admin_journey_path
    else
      @back_path = admin_root_path
      render template: 'admin/journeys/new_choose_route'
    end
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
    respond_to do |format|
      format.html
      format.csv { send_data @journey.csv, filename: "#{@journey.filename}.csv", type: 'text/csv;charset=utf-8' }
    end
  end

  def update
    @journey.update_attributes(journey_params)
    redirect_to admin_journey_path(@journey)
  end

  def destroy
    @journey.destroy
    redirect_to admin_journeys_path
  end

  # TODO: What does this do? This should be moved to the RoutesController anyway
  def surrounding_journeys
    @route = Route.find(params[:route_id])
    @previous_journeys = @route.journeys.where('start_time < ?', params[:datetime]).order('start_time DESC').limit(2)
    @next_journeys = @route.journeys.where('start_time > ?', params[:datetime]).order('start_time ASC').limit(2)
    render layout: false
  end

  def send_message
    bookings = params[:to] == 'all' ? @journey.bookings : [ @journey.bookings.find(params[:to]) ]
    bookings.each do |booking|
      SendSMS.enqueue(to: booking.phone_number, message: params[:notification_message])
    end
    flash[:notice] = "Message sent!"
    redirect_to admin_journey_path(@journey)
  end

  private

  def journey_params
    params.require(:journey).permit(:start_time, :vehicle_id, :supplier_id, :route_id, :open_to_bookings, :reversed)
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
