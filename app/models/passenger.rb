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
    passenger = Passenger.find_or_create_by(phone_number: phone_number)
    passenger.set_session_token
    passenger.set_verification_code
    passenger.send_notification!
    passenger
  end

  def self.formatted_phone_number(phone_number)
    if phone_number.present?
      @client = Twilio::REST::LookupsClient.new
      response = @client.phone_numbers.get(phone_number, country_code: 'GB')
      response.phone_number
    else
      false
    end
  rescue Twilio::REST::RequestError => e
    false
  end

  def active_bookings
    bookings.booked.includes(:journey).order('journeys.start_time ASC').select {|x| x.future?}
  end

  def past_bookings
    bookings.booked.includes(:journey).order('journeys.start_time DESC').select {|x| x.past?}
  end
  
  def send_notification!
    SendSMS.enqueue(to: phone_number, template: :verification_code, passenger: self.id)
  end
  
  def set_verification_code
    update_attribute(:verification_code, generate_verification_code)
  end
  
  def set_session_token
    update_attribute(:session_token, generate_session_token)
  end

  private
    
  def generate_verification_code
    (rand * 10000).to_i.to_s.rjust(4, "0")
  end
  
  def generate_session_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
