class SuggestedRoutesController < PublicController

  def new
    @page_title = "Suggest A Route"
    @back_path = routes_path
    @suggested_route = SuggestedRoute.new
  end

  def create
    @suggested_route = SuggestedRoute.create!(suggested_route_params)
    redirect_to routes_path
  end

  private

    def suggested_route_params
      params.require(:suggested_route).permit(:description).merge(passenger: current_passenger)
    end

end
