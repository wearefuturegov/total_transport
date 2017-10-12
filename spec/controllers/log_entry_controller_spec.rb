require 'rails_helper'

RSpec.describe LogEntryController, :que, type: :controller do
  let(:datetime) { '2017-01-01T09:00:00+00:00' }
  let(:from) { 'Some Place' }
  let(:to) { 'Some Other Place' }

  before(:each) { Timecop.freeze(datetime) }
  after(:each) { Timecop.return }
  
  it 'creates a failed place query with only an origin' do
    expect { post :create, from: from }.to change{
      QueJob.count
    }.by(1)
    job = QueJob.where(job_class: 'TrackFailedPlaceQuery').last
    expect(job.args).to eq([ from, nil, datetime])
  end
  
  it 'creates a failed place query with an origin and destination' do
    expect { post :create, from: from, to: to }.to change{
      QueJob.count
    }.by(1)
    job = QueJob.where(job_class: 'TrackFailedPlaceQuery').last
    expect(job.args).to eq([ from, to, datetime])
  end
  
end
