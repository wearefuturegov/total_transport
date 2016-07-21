class Suppliers::RoutesController < ApplicationController
  def create
    Route.create!
    redirect_to suppliers_routes_path
  end
  def show
    @route = Route.find(params[:id])
  end
  def destroy
    @route = Route.find(params[:id])
    @route.destroy
    redirect_to suppliers_routes_path
  end
  def sort
    @route = Route.find(params[:id])
    params[:stop].each_with_index do |value,index|
      @route.stops.find(value).update_attribute(:position,index+1)
    end
    render :nothing => true
  end
end
