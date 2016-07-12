class Suppliers::RoutesController < ApplicationController
  def create
    Route.create!
    redirect_to suppliers_routes_path
  end
  def show
    @route = Route.find(params[:id])
  end
end
