var dengie_center = [51.68149662336043, 0.8797645568847656]
var dengie_boundary = [
  {lat: 51.6901702956753, lng: 0.8618259429931641},
  {lat: 51.674205196246, lng: 0.8668899536132812},
  {lat: 51.67303420073919, lng: 0.8915233612060547},
  {lat: 51.67702610655534, lng: 0.8995914459228516},
  {lat: 51.68367850104477, lng: 0.8977031707763672},
  {lat: 51.68804194099285, lng: 0.8931541442871094},
  {lat: 51.68841441028611, lng: 0.8764171600341797},
  {lat: 51.69166008441168, lng: 0.8710098266601562}
]

var cold_norton_center = [51.72452936681463, 0.6766891479492188]
var cold_norton_boundary = [
  {lat: 51.67223577735361, lng: 0.6574630737304688},
  {lat: 51.66781758021604, lng: 0.6643295288085938},
  {lat: 51.66568817469938, lng: 0.6768608093261719},
  {lat: 51.664676672016455, lng: 0.6861305236816406},
  {lat: 51.664676672016455, lng: 0.6927394866943359},
  {lat: 51.67207609098759, lng: 0.69488525390625},
  {lat: 51.67564228571743, lng: 0.6903362274169922},
  {lat: 51.67787766759257, lng: 0.677032470703125},
  {lat: 51.67777122333861, lng: 0.6663894653320312},
  {lat: 51.675376161477864, lng: 0.6587505340576172}
]

var burnham_on_crouch_center = [51.63181717827266, 0.8149623870849609]
var burnham_on_crouch_boundary = [
  {lat: 51.63906216011215, lng: 0.8030319213867188},
  {lat: 51.63863601674617, lng: 0.8128166198730469},
  {lat: 51.638050063079405, lng: 0.8199405670166016},
  {lat: 51.637623910202784, lng: 0.8220863342285156},
  {lat: 51.63586598725761, lng: 0.8217430114746094},
  {lat: 51.632190110000586, lng: 0.8229446411132812},
  {lat: 51.63005903025397, lng: 0.8255195617675781},
  {lat: 51.62776800786233, lng: 0.8263778686523438},
  {lat: 51.62478417733435, lng: 0.8275794982910156},
  {lat: 51.62286589693901, lng: 0.825347900390625},
  {lat: 51.62419804470685, lng: 0.8167648315429688},
  {lat: 51.62537030239002, lng: 0.8099842071533203},
  {lat: 51.62537030239002, lng: 0.8029460906982422},
  {lat: 51.63053853192603, lng: 0.8009719848632812},
  {lat: 51.63671832204373, lng: 0.8007144927978516}
]

var maldon_center = [51.72452936681463, 0.6766891479492188];
var maldon_boundary = [
  {lat: 51.72782561421863, lng: 0.6669044494628906},
  {lat: 51.72617752055948, lng: 0.6657886505126953},
  {lat: 51.72394452362261, lng: 0.6650161743164062},
  {lat: 51.72102019417951, lng: 0.6661319732666016},
  {lat: 51.71862742031268, lng: 0.6651878356933594},
  {lat: 51.71825519966436, lng: 0.6699943542480469},
  {lat: 51.71825519966436, lng: 0.6749725341796875},
  {lat: 51.71830837423029, lng: 0.6793498992919922},
  {lat: 51.717244871031525, lng: 0.6818389892578125},
  {lat: 51.71953137198846, lng: 0.6879329681396484},
  {lat: 51.721870927707606, lng: 0.6919670104980469},
  {lat: 51.72538003431479, lng: 0.6881046295166016},
  {lat: 51.72856989488581, lng: 0.6887912750244141},
  {lat: 51.73245058839506, lng: 0.6847572326660156},
  {lat: 51.73165321281629, lng: 0.6810665130615234},
  {lat: 51.733407420520784, lng: 0.6773757934570312},
  {lat: 51.732291114404696, lng: 0.6732559204101562},
  {lat: 51.730324222257465, lng: 0.6679344177246094}
]

function draggableMap(centralPoint, boundary) {
  centralPoint = new google.maps.LatLng(centralPoint[0], centralPoint[1]);
  var map = new google.maps.Map(document.getElementById("map"), {
    zoom: 14,
    center: centralPoint,
    streetViewControl: false,
    mapTypeControl: false,
    zoomControl: false
  });

  map.set('styles', [{
    featureType: 'landscape',
    elementType: 'geometry',
    stylers: [
      { hue: '#00ff00' },
      { saturation: 30 },
      { lightness: 10}
    ]}
  ]);

  var polygon = new google.maps.Polygon({
    paths: boundary,
    strokeColor: '#FF0000',
    strokeOpacity: 0.8,
    strokeWeight: 2,
    fillColor: '#FF0000',
    fillOpacity: 0.35
  });
  polygon.setMap(map);

  $('<div/>').addClass('centerMarker').appendTo(map.getDiv());

  var last_position = centralPoint
  map.addListener('center_changed', function() {
    console.info(map.getCenter().toString())
    if(!google.maps.geometry.poly.containsLocation(map.getCenter(), polygon)) {
      map.setCenter(last_position);
    } else {
      last_position = map.getCenter();
    }
  });
}




function calculateRouteMultiStop(directionsService, directionsDisplay, map) {
    var waypts = [];
    var idNum = map.attr('id').slice(4);
    var checkboxArray = document.getElementById('select_'+idNum);
    var start = checkboxArray[0].value;
    var end = checkboxArray[(checkboxArray.length-1)].value;
    console.log(checkboxArray.length)
    for (var i = 0; i < checkboxArray.length; i++) {
      if (checkboxArray.options[i].selected) {
        waypts.push({
          location: checkboxArray[i].value,
          stopover: true
        });
      }
    }
    waypts.shift();
    waypts.pop();
    directionsService.route({
      origin: start,
      destination: end,
      waypoints: waypts,
      optimizeWaypoints: true,
      travelMode: google.maps.TravelMode.DRIVING
    }, function(response, status) {
      if (status === google.maps.DirectionsStatus.OK) {
        directionsDisplay.setDirections(response);
        var route = response.routes[0];
        console.log('DONE');
      } else {
        window.alert('Directions request failed due to ' + status);
      }
    });
  }