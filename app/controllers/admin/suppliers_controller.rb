class Admin::SuppliersController < AdminController
  before_filter :check_permissions

  def index
    @suppliers = Supplier.all
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def update
    @supplier = Supplier.find(params[:id])
    @supplier.update_attributes(supplier_params)
    redirect_to admin_suppliers_path
  end

  private
  def supplier_params
    params.require(:supplier).permit(:email, :phone_number, :name, :admin)
  end
end
