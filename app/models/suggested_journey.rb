class SuggestedJourney < ActiveRecord::Base
  belongs_to :passenger
  belongs_to :route
  belongs_to :booking
  
  after_create :run_dispatcher
  
  private
    
    def run_dispatcher
      RunDispatcher.enqueue(id)
    end
    
end
