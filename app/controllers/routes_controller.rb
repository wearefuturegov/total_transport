class RoutesController < ApplicationController
  def index
    @page_title = "Choose Your Route"
    @routes = Route.bookable_routes
  end

  def suggest_route
    @page_title = "Suggest A Route"
    @back_path = routes_path
    if request.method == 'POST'
      @suggested_route = SuggestedRoute.create!(suggested_route_params)
      redirect_to routes_path
    else
      @suggested_route = SuggestedRoute.new
    end
  end

  private

  def suggested_route_params
    params.require(:suggested_route).permit(:description).merge(passenger: current_passenger)
  end
end
