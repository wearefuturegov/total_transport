class Admin::SupplierSuggestionsController < AdminController
  def new
    @supplier_suggestion = SupplierSuggestion.new(url: params[:from_url])
  end

  def create
    @supplier_suggestion = SupplierSuggestion.create!(supplier_params)
    redirect_to URI.parse(@supplier_suggestion.url).path
  end

  private

  def supplier_params
    params.require(:supplier_suggestion).permit(:description, :url).merge(supplier: current_supplier)
  end
end
