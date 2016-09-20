class Passenger < ActiveRecord::Base
  has_many :bookings, dependent: :destroy
  has_many :suggested_journeys, dependent: :destroy
  has_many :suggested_edit_to_stops, dependent: :destroy
  has_many :suggested_routes, dependent: :destroy
  has_many :payment_methods, dependent: :destroy

  has_attached_file :photo, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }

  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
  validate :validate_phone_number, on: :create

  def send_verification!
    set_verification_code
    send_notification!("Your verification code is #{self.verification_code}")
  end

  def set_verification_code
    self.update_attribute(:verification_code, (rand * 10000).to_i)
  end

  def send_notification!(message)
    @client = Twilio::REST::Client.new
    @client.messages.create(
      from: TWILIO_PHONE_NUMBER,
      to: self.phone_number,
      body: message
    )
  end

  def validate_phone_number
    @client = Twilio::REST::LookupsClient.new
    response = @client.phone_numbers.get(self.phone_number, country_code: 'GB')
    self.phone_number = response.phone_number
  rescue Twilio::REST::RequestError => e
    errors.add(:phone_number, "is not a valid phone number")
  end
end
