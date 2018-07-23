class Admin::TeamsController < AdminController
  before_action :check_permissions, except: [:show]
  before_action :get_team, only: [:edit, :update]
  
  def show
    @back_path = admin_root_path
  end
  
  def index
    @teams = Team.all
  end
  
  def edit
  end
  
  def update
    team_params[:suppliers_attributes]&.values&.each do |s|
      supplier = Supplier.find(s[:id])
      supplier.team = @team
      supplier.save
    end
    @team.update_attributes(team_params)
    redirect_to admin_teams_url, notice: 'Team updated!'
  end
  
  private
  
    def get_team
      @team = Team.find(params[:id])
    end

    def team_params
      params.require(:team).permit(:name, :email, suppliers_attributes: [:id])
    end
end
