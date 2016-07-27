class Vehicle < ActiveRecord::Base
  belongs_to :team
  has_many :journeys
end
