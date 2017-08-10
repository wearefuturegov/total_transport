class Team < ActiveRecord::Base
  has_many :suppliers
  has_many :vehicles
  has_many :journeys, through: :suppliers
  
  after_create :set_name

  def solo_team?
    suppliers.count < 2
  end

  def empty_team?
    suppliers.count == 0
  end

  def single_vehicle?
    vehicles.count < 2
  end
  
  private
  
    def set_name
      if name.blank? && suppliers.length > 0
        update(name: "#{suppliers.first.name}'s Team")
      end
    end
end
