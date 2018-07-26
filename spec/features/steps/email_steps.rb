module EmailSteps
  
  step 'I should receive a cancellation email' do
    QueJob.where(job_class: 'SendEmail').each do |j|
      j.job_class.constantize.send(:run, *j.args)
    end
    expect(unread_emails_for(@booking.passenger.email).count).to eq(1)
  end
  
end

RSpec.configure do |config|
  config.include EmailSteps, type: :feature
end
