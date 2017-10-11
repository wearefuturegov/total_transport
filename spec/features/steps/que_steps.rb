step 'the origin :origin should be logged' do |origin|
  expect(QueJob.where(job_class: 'TrackFailedPlaceQuery').last.args[0]).to eq(origin)
end

step 'the destination :destination should be logged' do |destination|
  expect(QueJob.where(job_class: 'TrackFailedPlaceQuery').last.args[1]).to eq(destination)
end
