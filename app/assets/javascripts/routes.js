$(document).ready(function() {
  var numOfRoutes = $('.route').length;

  $('.input-cont input[name="from"]').keyup(function() {
    // On input change
    var tempTxt = $( this ).val();
    if ($( this ).val().length > 2) {
      // Only fire if above 3 characters
      checkRoutes(tempTxt);

      // REMOVE ONCE DONE WITH USER TEST
      var farmCheck = 'Landwick Farm';
      if (farmCheck.toLowerCase().indexOf(tempTxt.toLowerCase()) >= 0) {
        $('#farm').css('font-weight', 600);
        if (!$('#farmBtn').parent('.route').hasClass('open')) {
          $('#farmBtn').click();
        }
      }
    } else {
      $('.route').each(function() {
        // the text is 2 char or below, reveal any hidden routes 
        $(this).slideDown();
        $(this).removeClass('vis');
        $('#farm').css('font-weight', 400);
      });
    }
  });

  $('.input-cont input[name="to"]').keyup(function() {
    // On input change
    var tempTxt = $( this ).val();
    if ($( this ).val().length > 2) {
      // Only fire if above 3 characters
      checkRoutes(tempTxt);

      // REMOVE ONCE DONE WITH USER TEST
      var cinemCheck = 'Reel Cinema';
      if (cinemCheck.toLowerCase().indexOf(tempTxt.toLowerCase()) >= 0) {
        $('#cinema').css('font-weight', 600);
      }
    } else {
      $('.route').each(function() {
        // the text is 2 char or below, reveal any hidden routes 
        $(this).slideDown();
        $(this).removeClass('vis');
        $('#cinema').css('font-weight', 400);
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
        $(this).closest('.route').removeClass('vis');
      }
    });
    
    $(exception).each(function(index, item) {
      // after checking all that add the vis class to all that need it
      $('#'+item).addClass('vis');
    });
    $('.route').each(function() {
      // run through all routes - if they dont have the vis class - kill them
      if(!$(this).hasClass('vis')) {
        $(this).slideUp();
      }
    });
  }
});