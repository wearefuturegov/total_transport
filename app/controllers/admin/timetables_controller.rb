class Admin::TimetablesController < AdminController

  def new
    @timetable = Timetable.new
    @routes = Route.all
  end
  
  def create
    if Timetable.create(timetable_params)
      redirect_to admin_journeys_path
    else
      render :new
    end
  end
  
  private
  
  def timetable_params
    params.require(:timetable).permit(
      :route_id,
      :supplier_id,
      :vehicle_id,
      :from,
      :to,
      :open_to_bookings,
      :reversed,
      days: [],
      timetable_times_attributes: [
        :time,
        stops: []
      ]
    )
  end

end
