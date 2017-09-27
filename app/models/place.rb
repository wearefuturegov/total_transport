class Place < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :stops
  has_many :routes, through: :stops
  
  default_scope { order(name: :asc) }
  
  validates_presence_of :name, :latitude, :longitude
  
  def lat_lng
    Geokit::LatLng.new(self.latitude, self.longitude)
  end
end