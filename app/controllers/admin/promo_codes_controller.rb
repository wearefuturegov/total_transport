class Admin::PromoCodesController < AdminController
  before_filter :check_permissions

  def index
    @promo_codes = PromoCode.all
    @promo_code = PromoCode.new
  end

  def create
    @promo_code = PromoCode.create!(promo_code_params)
    redirect_to admin_promo_codes_path
  end

  def destroy
    @promo_code = PromoCode.find(params[:id])
    @promo_code.destroy
    redirect_to admin_promo_codes_path
  end

  private

  def promo_code_params
    params.require(:promo_code).permit(:price_deduction)
  end
end
