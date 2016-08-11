class SuggestedEditToStop < ActiveRecord::Base
  belongs_to :passenger
  belongs_to :stop
end
