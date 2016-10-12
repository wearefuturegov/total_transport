class Admin::SuppliersController < AdminController
  before_filter :check_permissions

  def index
    @suppliers = Supplier.all
    @back_path = admin_team_path
  end

  def edit
    @supplier = Supplier.find(params[:id])
    @back_path = admin_suppliers_path
  end

  def update
    @supplier = Supplier.find(params[:id])
    @supplier.update_attributes(supplier_params)
    redirect_to admin_suppliers_path
  end

  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.destroy!
    redirect_to admin_suppliers_path
  end

  private
  def supplier_params
    params.require(:supplier).permit(:email, :phone_number, :name, :admin, :approved)
  end
end
