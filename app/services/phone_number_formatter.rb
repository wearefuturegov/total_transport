class PhoneNumberFormatter
  
  def initialize(number)
    @client = Twilio::REST::Client.new
    @number = number
  end
  
  def format
    return false unless @number.present?
    response = @client.lookups.phone_numbers(@number.delete(' ')).fetch(country_code: 'GB')
    response.phone_number
  rescue Twilio::REST::TwilioError, Twilio::REST::RestError => e
    false
  end
  
end
