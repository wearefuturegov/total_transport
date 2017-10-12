class LogEntryController < PublicController

  def create
    TrackFailedPlaceQuery.enqueue(params[:from], params[:to], DateTime.now.to_s)
    head 202, "content_type" => 'text/plain'
  end

end
