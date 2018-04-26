class Passenger < ActiveRecord::Base
  
  has_many :bookings, dependent: :destroy
  has_many :suggested_journeys, dependent: :destroy
  has_many :suggested_edit_to_stops, dependent: :destroy
  has_many :suggested_routes, dependent: :destroy

  has_attached_file :photo, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }
  
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
  
  def anonymise!
    update_attributes(name: nil, email: nil, phone_number: nil)
    save
  end
end
