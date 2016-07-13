class Route < ActiveRecord::Base
  has_many :stops, -> { order(position: :asc) }
  def name
    if stops.count > 1
      "Route #{self.id}: #{self.stops.first.name} - #{self.stops.last.name}"
    else
      "Route #{self.id}"
    end
  end
end
