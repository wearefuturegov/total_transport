class CloseBeforeEnd < Que::Job
  
  def run(journey_id)
    begin
      journey = Journey.find(journey_id)
      ActiveRecord::Base.transaction do
        journey.update_attribute(:open_to_bookings, false)
        destroy
      end
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
