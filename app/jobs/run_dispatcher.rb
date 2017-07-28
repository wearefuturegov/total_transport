class RunDispatcher < Que::Job
  
  def run(suggested_journey_id)
    begin
      suggested_journey = SuggestedJourney.find(suggested_journey_id)
      ActiveRecord::Base.transaction do
        Dispatcher.new(suggested_journey).perform!
        destroy
      end
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end
  
end
