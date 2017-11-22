module BookingsHelper

  def map(lat, lng, width = 1000, height = 175)
    url = generate_url(lat, lng, width, height)
    data = get_data(url)
    data_url = "data:image/png;base64,#{data}"
    image_tag data_url
  end

  def bus_passes
    options_for_select([
      ['Please select', ''],
      ['Older Persons Bus Pass', 'older_bus_passes'],
      ['Disabled Bus Pass', 'disabled_bus_passes']
    ])
  end

  private

    def generate_url(lat, lng, width, height)
      base = 'https://api.mapbox.com/v4/mapbox.streets'
      geojson = URI.escape "{\"type\":\"Point\",\"coordinates\":[#{lng},#{lat}]}", '"{}[]'
      centre_and_zoom = "#{lng},#{lat},15"
      size = "#{width}x#{height}"
      access_token = ENV['MAPBOX_ACCESS_TOKEN']
      "#{base}/geojson(#{geojson})/#{centre_and_zoom}/#{size}.png?access_token=#{access_token}"
    end

    def get_data(url)
      body = open(url).read
      Base64.encode64(body)
    end

end
