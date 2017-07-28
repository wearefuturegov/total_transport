class Team < ActiveRecord::Base
  has_many :suppliers
  has_many :vehicles
  has_many :journeys, through: :suppliers
  has_many :generated_journeys, through: :vehicles

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
  
  def generated_journeys
    super.order(:id).uniq
  end
end
