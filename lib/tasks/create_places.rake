require 'open-uri'
desc 'Create places for a specific county'
namespace :places do
  task :create => :environment do
    county_id = ENV['COUNTY'].nil? ? '7000000000019687' : ENV['COUNTY']
    county = "http://data.ordnancesurvey.co.uk/id/#{county_id}"

    # This query tells the OS Linked Data API to fetch up all the Villages, Towns,
    # Cities and Hamlets in Essex
    sparql = """
    PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    PREFIX spatial: <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/>
    PREFIX open: <http://data.ordnancesurvey.co.uk/ontology/OpenNames/>
    PREFIX wgs: <http://www.w3.org/2003/01/geo/wgs84_pos#>
    SELECT ?uri ?label ?type ?lat ?lng
    WHERE {
      ?uri spatial:within <#{county}> .
      {
         { ?uri open:populatedPlace open:Village }
           UNION
         { ?uri open:populatedPlace open:Town }
           UNION
         { ?uri open:populatedPlace open:City }
           UNION
         { ?uri open:populatedPlace open:Hamlet }
           UNION
         {
           ?uri open:populatedPlace ?x .
           FILTER (str(?x) = 'http://data.ordnancesurvey.co.uk/ontology/OpenNames/Suburban Area') .
         }
      } .
      ?uri foaf:name ?label.
      ?uri open:populatedPlace ?type.
      ?uri wgs:lat ?lat.
      ?uri wgs:long ?lng.
    }
    ORDER BY DESC(?label)
    """

    # Make the query
    url = "http://data.ordnancesurvey.co.uk/datasets/opennames/apis/sparql?query=#{CGI.escape sparql}"
    body = open(url).read
    json = JSON.parse(body)

    # Create a place for all the results
    json['results']['bindings'].each do |r|
      puts r['label']['value']
      Place.find_or_create_by(name: r['label']['value']) do |place|
        place.latitude = r['lat']['value'].to_f
        place.longitude = r['lng']['value'].to_f
      end
    end
  end
end
