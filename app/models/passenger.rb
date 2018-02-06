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
  
  def self.setup(phone_number)
    phone_number = formatted_phone_number(phone_number)
    passenger = Passenger.find_or_create_by(phone_number: phone_number)
    passenger.set_session_token
    passenger
  end

  def self.formatted_phone_number(phone_number)
    return false unless phone_number.present?
    @client = Twilio::REST::Client.new
    response = @client.lookups.phone_numbers(phone_number.delete(' ')).fetch(country_code: 'GB')
    response.phone_number
  rescue Twilio::REST::TwilioError, Twilio::REST::RestError => e
    false
  end
  
  def set_session_token
    update_attribute(:session_token, generate_session_token)
  end

  private
  
  def generate_session_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
