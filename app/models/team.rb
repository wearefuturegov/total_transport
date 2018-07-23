class Team < ApplicationRecord
  has_many :suppliers
  has_many :journeys
  
  after_create :set_name
  
  accepts_nested_attributes_for :suppliers

  def solo_team?
    suppliers.count < 2
  end

  def empty_team?
    suppliers.count == 0
  end
  
  private
  
    def set_name
      if name.blank? && suppliers.length > 0
        update(name: "#{suppliers.first.name}'s Team")
      end
    end
end
