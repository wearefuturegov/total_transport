// Helper method for a less zoomed out google maps fitBounds()
// See http://shades-of-orange.com/post/Remove-The-Padding-From-The-Google-Map-API-v3-fitBounds()-Method
// For more info
function tightFitBounds(myMap, bounds) {
    myMap.fitBounds(bounds); // calling fitBounds() here to center the map for the bounds

    var overlayHelper = new google.maps.OverlayView();
    overlayHelper.draw = function () {
        if (!this.ready) {
            var extraZoom = getExtraZoom(this.getProjection(), bounds, myMap.getBounds());
            if (extraZoom > 0) {
                myMap.setZoom(myMap.getZoom() + extraZoom);
            }
            this.ready = true;
            google.maps.event.trigger(this, 'ready');
        }
    };
    overlayHelper.setMap(myMap);
}

function getExtraZoom(projection, expectedBounds, actualBounds) {

    // in: LatLngBounds bounds -> out: height and width as a Point
    function getSizeInPixels(bounds) {
        var sw = projection.fromLatLngToContainerPixel(bounds.getSouthWest());
        var ne = projection.fromLatLngToContainerPixel(bounds.getNorthEast());
        return new google.maps.Point(Math.abs(sw.y - ne.y), Math.abs(sw.x - ne.x));
    }

    var expectedSize = getSizeInPixels(expectedBounds),
        actualSize = getSizeInPixels(actualBounds);

    if (Math.floor(expectedSize.x) == 0 || Math.floor(expectedSize.y) == 0) {
        return 0;
    }

    var qx = actualSize.x / expectedSize.x;
    var qy = actualSize.y / expectedSize.y;
    var min = Math.min(qx, qy);

    if (min < 1) {
        return 0;
    }

    return Math.floor(Math.log(min) / Math.LN2 /* = log2(min) */);
}
