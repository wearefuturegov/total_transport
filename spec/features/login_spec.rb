require 'rails_helper'

feature 'User logs in', type: :feature, js: true do
  
  before do
    visit('/')
  end

  it 'Successful login for new user' do
    expect {
      enter_phone_number('+15005550006')
    }.to change { FakeSMS.messages.count }.by(1)
    verification_code = Passenger.last.verification_code
    expect(FakeSMS.messages.first[:body]).to eq("Your verification code is #{verification_code}")
    enter_verification_code(verification_code)
    expect(page).to have_content('Choose Your Route')
  end
  
  it 'Login attempt with invalid phone number format' do
    enter_phone_number('4534543')
    expect(page).to have_content('Phone number is not a valid, please try another one')
  end
  
  it 'Login attempt with no phone number' do
    enter_phone_number('')
    expect(page).to have_content('Phone number is not a valid, please try another one')
  end
  
  it 'Login attempt with invalid verification code' do
    enter_phone_number('+15005550006')
    enter_verification_code('1234')
  end
  
  private
  
    def enter_phone_number(phone_number)
      first(:css, '#passenger_phone_number').set(phone_number)
      first('input[value="Verify Number"]').click
    end
  
    def enter_verification_code(code)
      code.split('').each_with_index do |num, i|
        fill_in "digit#{i + 1}", with: num
      end
      click_button 'Verify'
    end

end
