class Place < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :stops
  has_many :routes, through: :stops
  
  default_scope { order(name: :asc) }
  
  validates_presence_of :name
  validates_presence_of :latitude, message: 'You must choose a location'
  validates_presence_of :longitude, message: 'You must choose a location'
  
  def route_count
    routes.length
  end
  
  def self.possible_destinations(start_place)
    routes = start_place.routes
    places = routes.map { |r| r.places }
    places.flatten.reject { |p| p.slug == start_place.slug }
  end
  
  def lat_lng
    Geokit::LatLng.new(self.latitude, self.longitude)
  end
end
