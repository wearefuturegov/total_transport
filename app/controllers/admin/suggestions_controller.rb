class Admin::SuggestionsController < AdminController
  def index
    @suggested_journeys = SuggestedJourney.all
    @suggested_routes = SuggestedRoute.all
    @suggested_edit_to_stops = SuggestedEditToStop.all
    @supplier_suggestions = SupplierSuggestion.all
    @back_path = admin_team_path
  end
end
