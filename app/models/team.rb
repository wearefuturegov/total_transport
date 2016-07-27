class Team < ActiveRecord::Base
  has_many :suppliers
  has_many :vehicles

  def name
    if attributes[:name].blank?
      suppliers.first.name + "'s Team"
    else
      super
    end
  end
end
