class Admin::PlacenamesController < AdminController

  def index
    results = PlacenamesService.new(params[:query]).search
    render json: results
  end

end
