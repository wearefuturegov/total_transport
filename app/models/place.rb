class Place < ActiveRecord::Base
  has_many :stops
  
  default_scope { order(name: :asc) }
  
  def lat_lng
    Geokit::LatLng.new(self.latitude, self.longitude)
  end
end
