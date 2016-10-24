$(document).ready(function() {
  var numOfRoutes = $('.full-route').length;

  $('#filter').change(function() {
    if ($('#filter option:selected').val() > 0) {
      $('.full-route').each(function() {
        // the text is 2 char or below, reveal any hidden routes 
        $(this).slideDown();
        $(this).removeClass('filtered');
      });
      checkRoutes($('#filter option:selected').html());
    } else {
      $('.full-route').each(function() {
        // the text is 2 char or below, reveal any hidden routes 
        $(this).slideDown();
        $(this).removeClass('filtered');
      });
      $('#total-route-number').html($('.full-route').length);
    }
  });

  function checkRoutes(tempTxt) {
    var exception = [];
    console.log(tempTxt);
    $('.full-route .non-reverse .acord li').each(function() {
      // for each list item
      if ($(this).html().toLowerCase().indexOf(tempTxt.toLowerCase()) >= 0) {
        // check if it contains the same text 
        // if so add to id array 
        exception.push($(this).closest('.full-route').attr('id'));
      } else {
        // if not remove vis class
        $(this).closest('.full-route').removeClass('filtered');
      }
    });
    $(exception).each(function(index, item) {
      // after checking all that add the vis class to all that need it
      $('#'+item).addClass('filtered');
    });
    $('.full-route').each(function() {
      // run through all routes - if they dont have the vis class - kill them
      if(!$(this).hasClass('filtered')) {
        $(this).slideUp();
      }
    });
    $('#total-route-number').html(exception.length);
  }
});