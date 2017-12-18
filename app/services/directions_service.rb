class DirectionsService
  
  ACCESS_TOKEN = ENV['MAPBOX_ACCESS_TOKEN']
  
  def initialize(latlngs)
    latlngs = URI::encode latlngs.join(';')
    @url = "https://api.mapbox.com/directions/v5/mapbox/driving/#{latlngs}.json?overview=full&access_token=#{ACCESS_TOKEN}"
  end
  
  def results
    @results ||= JSON.parse open(@url).read
  end
  
  def total_duration
    (results['routes'][0]['duration'] / 60).round
  end
  
  def geometry
    Polylines::Decoder.decode_polyline results['routes'][0]['geometry']
  end

end
