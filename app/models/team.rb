class Team < ActiveRecord::Base
  has_many :suppliers
  has_many :vehicles
  has_many :journeys, through: :suppliers

  def name
    if attributes[:name].blank?
      suppliers.first.name + "'s Team"
    else
      super
    end
  end

  def solo_team?
    suppliers.count < 2
  end

  def empty_team?
    suppliers.count == 0
  end

  def single_vehicle?
    vehicles.count < 2
  end
end
