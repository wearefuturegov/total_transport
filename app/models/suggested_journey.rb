class SuggestedJourney < ApplicationRecord
  belongs_to :passenger
  belongs_to :route
end
