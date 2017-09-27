step 'I should get an SMS with a confirmation code' do
  expect(FakeSMS.messages.count).to eq(1)
  expect(FakeSMS.messages.last[:body]).to match /Your verification code is/
  FakeSMS.messages = []
end

step 'I should recieve an SMS confirming my booking' do
  expect(FakeSMS.messages.count).to eq(1)
  expect(FakeSMS.messages.last[:body]).to match /is confirmed/
  FakeSMS.messages = []
end
