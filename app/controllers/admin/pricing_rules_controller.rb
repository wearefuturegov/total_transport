class Admin::PricingRulesController < AdminController
  
  def index ; end
  
  def new
    @pricing_rule = PricingRule.new
  end

  def create
    if PricingRule.create(pricing_rules_params)
      redirect_to admin_pricing_rules_url
    else
      render :new
    end
  end
  
  def update ; end
  
  def destroy ; end
  
  private
  
    def pricing_rules_params
      params.require(:pricing_rule).permit(
        :name,
        :rule_type,
        :per_mile,
        :stages,
        :child_multiplier,
        :return_multiplier,
        :allow_concessions
      )
    end

end
