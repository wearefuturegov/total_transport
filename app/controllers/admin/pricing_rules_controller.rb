class Admin::PricingRulesController < AdminController
  before_filter :get_pricing_rule, only: [:edit, :update]
  
  def index
    @pricing_rules = PricingRule.all
  end
  
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
  
  def edit ; end
  
  def update
    if @pricing_rule.update(pricing_rules_params)
      redirect_to admin_pricing_rules_url
    else
      render :edit
    end
  end
  
  def destroy ; end
  
  private
  
    def pricing_rules_params
      params.require(:pricing_rule).permit(
        :name,
        :rule_type,
        :per_mile,
        :stages,
        :child_fare_rule,
        :child_flat_rate,
        :child_multiplier,
        :return_multiplier,
        :allow_concessions
      )
    end
    
    def get_pricing_rule
      @pricing_rule = PricingRule.find(params[:id])
    end

end
