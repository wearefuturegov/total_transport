class SuggestedJourney < ActiveRecord::Base
  belongs_to :passenger
  belongs_to :route
end
