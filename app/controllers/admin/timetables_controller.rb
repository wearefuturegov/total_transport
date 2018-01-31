class Admin::TimetablesController < AdminController
  
  before_filter :get_routes, only: [:new, :edit]
  
  def index
    @timetables = Timetable.all
  end
  
  def new
    @timetable = Timetable.new
  end
  
  def create
    if Timetable.create(timetable_params)
      redirect_to admin_timetables_path
    else
      render :new
    end
  end
  
  private
  
  def timetable_params
    params.require(:timetable).permit(
      :route_id,
      :supplier_id,
      :from,
      :to,
      :open_to_bookings,
      :reversed,
      days: [],
      timetable_times_attributes: [
        :time,
        :seats,
        stops: []
      ]
    )
  end
  
  def get_routes
    @routes = Route.all
  end

end
