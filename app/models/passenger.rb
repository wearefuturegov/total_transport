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

  def send_verification!
    set_verification_code
    @client = Twilio::REST::Client.new
    @client.messages.create(
      from: '+441173252034',
      to: self.phone_number,
      body: "Your verification code is #{self.verification_code}"
    )
  end

  def set_verification_code
    self.update_attribute(:verification_code, (rand * 10000).to_i)
  end
end
