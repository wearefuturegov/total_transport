step 'the origin :origin should be logged' do |origin|
  expect(QueJob.where(job_class: 'TrackFailedPlaceQuery').last.args[0]).to eq(origin)
end

step 'the destination :destination should be logged' do |destination|
  expect(QueJob.where(job_class: 'TrackFailedPlaceQuery').last.args[1]).to eq(destination)
end

step 'my alerts should be cancelled' do
  jobs = QueJob.where("args::json->2->>'booking_id' = ? AND job_class = 'SendEmail'", @booking.id.to_s).to_a.to_a.reject! {
    |j| j.args[1] == 'booking_cancelled' || j.args[1] == 'user_cancellation'
  }
  expect(jobs.count).to eq(0)
end
