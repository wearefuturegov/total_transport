$.fn.routeMap = function() {
  
  if (this.length === 0) { return false; }
  
  var $map = $(this);
  var geometry = $map.data('geometry');
  
  if (typeof(geometry) == 'object') {
    
    $map.uniqueId();
    
    var geoJSON = L.geoJSON({
      "type": "LineString",
      "coordinates": geometry
    });
    
    var id = $map.attr('id');
    var map = L.map(id);
    
    L.tileLayer('https://api.mapbox.com/styles/v1/wearefuturegov/cj8pp146j9uyv2rojanc93qtf/tiles/256/{z}/{x}/{y}?access_token={accessToken}', {
      maxZoom: 18,
      id: 'mapbox.streets',
      accessToken: 'pk.eyJ1Ijoid2VhcmVmdXR1cmVnb3YiLCJhIjoiY2o3dDc4bGpoNGd2ajJ3bWp4ZWg3dWd0YiJ9.SbUuzZNHrNFQmgjtYUTU-A'
    }).addTo(map);
    
    geoJSON.addTo(map);
    map.fitBounds(geoJSON.getBounds());
    map.scrollWheelZoom.disable();
    
  }
  
}
