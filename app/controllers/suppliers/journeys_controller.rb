class Suppliers::JourneysController < ApplicationController
  before_filter :find_route
  def index
    @journeys = @route.journeys
  end

  def create
    @route.journeys.create!(journey_params)
    redirect_to suppliers_route_journeys_path(@route)
  end

  def edit
    @journey = @route.journeys.find(params[:id])
  end

  def update
    @journey = @route.journeys.find(params[:id])
    @journey.update_attributes(journey_params)
    redirect_to suppliers_route_journeys_path(@route)
  end

  def destroy
    @journey = @route.journeys.find(params[:id])
    @journey.destroy
    redirect_to suppliers_route_journeys_path(@route)
  end

  private
  def find_route
    @route = Route.find(params[:route_id])
  end

  def journey_params
    params.require(:journey).permit(:start_time)
  end
end
