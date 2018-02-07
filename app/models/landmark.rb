class Landmark < ActiveRecord::Base
  belongs_to :stop
  attr_accessor :postcode
  
  before_save :get_latlng_from_postcode
  
  def name
    if super.blank?
      "Unnamed Landmark"
    else
      super
    end
  end
  
  def copy
    landmark = self.dup
    landmark.save
    landmark
  end
  
  private
  
    def get_latlng_from_postcode
      return if postcode.nil?
      result = Postcodes::IO.new.lookup(postcode)
      self.latitude = result.latitude
      self.longitude = result.longitude
      return true
    end
  
end
