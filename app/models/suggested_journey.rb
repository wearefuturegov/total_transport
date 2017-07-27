class SuggestedJourney < ActiveRecord::Base
  belongs_to :passenger
  belongs_to :route
  belongs_to :booking
end
