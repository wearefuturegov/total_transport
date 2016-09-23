class RoutesController < ApplicationController
  def index
    @page_title = "Choose Your Route"
    @top_sec = "These routes are flexible and show the general areas that your NAME will pass through."
  end

  def suggest_route
    @page_title = "Suggest A Route"
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
