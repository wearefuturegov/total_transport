$(document).ready(function() {
  var numOfRoutes = $('.route').length;

  $('#filter').keyup(function() {
    var tempTxt = $( this ).val();
    if (tempTxt.length > 2) {
      checkRoutes(tempTxt);
    } else {
      $('.route').each(function() {
        // the text is 2 char or below, reveal any hidden routes 
        $(this).slideDown();
        $(this).removeClass('filtered');
      });
    }
  });

  function checkRoutes(tempTxt) {
    var exception = [];
    $('.route .acord li').each(function() {
      // for each list item
      if ($(this).html().toLowerCase().indexOf(tempTxt.toLowerCase()) >= 0) {
        // check if it contains the same text 
        // if so add to id array 
        exception.push($(this).closest('.route').attr('id'));
        
      } else {
        // if not remove vis class
        $(this).closest('.route').removeClass('filtered');
      }
    });
    
    $(exception).each(function(index, item) {
      // after checking all that add the vis class to all that need it
      $('#'+item).addClass('filtered');
    });
    $('.route').each(function() {
      // run through all routes - if they dont have the vis class - kill them
      if(!$(this).hasClass('filtered')) {
        $(this).slideUp();
      }
    });
  }
});