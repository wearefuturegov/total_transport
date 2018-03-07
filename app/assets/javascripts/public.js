$(document).ready(function() {
  
  $('#public-index .book').bookingHome();
  
  $('body.pricing_rules').pricingRules();
  
  $('.route_preview').routeMap();
  
  $('#admin').warnUnsaved();
  
})
