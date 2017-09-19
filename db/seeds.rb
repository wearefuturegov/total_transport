require 'open-uri'

# Specify a County. In this case, Essex
county = "http://data.ordnancesurvey.co.uk/id/7000000000019687"

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
  Place.create(name: r['label']['value'], latitude: r['lat']['value'].to_f, longitude: r['lng']['value'].to_f)
end
