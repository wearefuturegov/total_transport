class Team < ActiveRecord::Base
  has_many :suppliers
  has_many :vehicles
end
