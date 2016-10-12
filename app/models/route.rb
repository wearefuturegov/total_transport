class Route < ActiveRecord::Base
  has_many :stops, -> { order(position: :asc) }, dependent: :destroy
  has_many :journeys, -> { order(start_time: :asc) }, dependent: :destroy
  has_many :suggested_journeys, dependent: :destroy

  def self.bookable_routes
    all.reject {|route| route.stops.count <= 2}
  end

  def name
    if stops.count > 1
      "Route #{self.id}: #{self.stops.first.name} - #{self.stops.last.name}"
    else
      "Route #{self.id}"
    end
  end

  def forwards_name
    "#{stops.first.name} - #{stops.last.name}"
  end

  def backwards_name
    "#{stops.last.name} - #{stops.first.name}"
  end

  def has_available_journeys?
    journeys.available.any?
  end

  def available_journeys_by_date
    available_journeys_by_date = {}
    journeys.available.each do |journey|
      available_journeys_by_date[journey.start_time.to_date] ||= []
      available_journeys_by_date[journey.start_time.to_date] << journey
    end
    available_journeys_by_date
  end
end
