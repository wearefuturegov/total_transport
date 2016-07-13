class Suppliers::RoutesController < ApplicationController
  def create
    Route.create!
    redirect_to suppliers_routes_path
  end
  def show
    @route = Route.find(params[:id])
  end
  def sort
    @route = Route.find(params[:id])
    params[:stop].each_with_index do |value,index|
      @route.stops.find(value).update_attribute(:position,index)
    end
    render :nothing => true
  end
end
