class Vehicle < ActiveRecord::Base
  belongs_to :team
  has_many :journeys, dependent: :destroy
  validates_presence_of :team, :seats, :registration
end
