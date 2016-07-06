$(document).ready(function() {
  var activeDots = 0;
  var numOfStops = $('.stop').length;
  var stopNumber = 0;
  var pkupTxt = 'Select Pick Up Location';
  var drpfTxt = 'Select Drop Off Location';
  var cnfmTxt = 'Confirm Route';
  $('.stop').last().addClass('lastChild');

  // If a stop is clicked
  $('.stop').click(function() {
    // If it has already been clicked - Revert
    if ($(this).hasClass('active')) {
      // lower the current global of active dots
      activeDots--;
      // remove its active class
      $(this).removeClass('active');
      // remove the alive class from its child
      $(this).find('.stop-dot-line').removeClass('alive');
      $(this).find('.stop-dot-line').removeAttr('style');
      // If there is still another dot active move the global trackers onto that stop
      if (activeDots == 1) {
        $('h1').html(drpfTxt);
        clearStopLine();
        stopNumber = $('.stop.active').data("stopnum");
        $('.stop.active').find('.stop-dot-line').addClass('alive');
      } else {
        // if there is no other stop remaining active reset to the start
        $('h1').html(pkupTxt);
        clearStopLine();
        stopNumber = 0;
        $('.lastChildOff').addClass('lastChild');
        $('.lastChildOff').removeClass('lastChildOff');
      }
      
    } else {
      // if it is not active - Make active
      if (activeDots < 2) {
        drawStopLine(stopNumber, $(this).data("stopnum"));
        // Only allow this if no more than 2 dots are active
        activeDots++;
        $('.lastChild').addClass('lastChildOff');
        $('.lastChild').removeClass('lastChild');
        $(this).addClass('active');
        // if its the first dot store the globals and set title
        if (activeDots == 1) {
          $('h1').html(drpfTxt);
          $(this).find('.stop-dot-line').addClass('alive');
          stopNumber = $(this).data("stopnum");
        } else if(activeDots == 2) {
          $('h1').html(cnfmTxt);
          //TRYING TO ADD A SYSTEM - that will blank out the start location 
          //if there is two clicked - so you can only cancel the last dot that has been clicked?
          //$('.stop').data('stopNum', stopNumber).addClass('start');
        }
      }
    }
  });


  if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
    //IF MOBILE IT DOES NOT DO HOVER EFFECTS

  } else {
    $('.stop').hover(function() {
      // check if its not the last stop
      if ($(this).hasClass('lastChild')) {
        // it is the last stop
        $(this).addClass('lastHover');
      } else {
        // if on hover there is only one dot draw a line from the first dot to the current hover
        if (stopNumber != 0 && activeDots == 1) {
          var potentialStop = $(this).data("stopnum");
          drawStopLine(stopNumber, potentialStop);
        }
        // only add the hover state if there is less than 2 dots active
        if (activeDots >= 2) {
          if ($(this).hasClass('active')) {
            $(this).addClass('hover');
          }
        } else {
          $(this).addClass('hover');
        }
      }

    // reset this on mouse out
    }, function() {
        $(this).removeClass('hover');
        $(this).removeClass('lastHover');
        //clearStopLine();
    });
  }
});


function drawStopLine(begin, end) {
  if (begin == end) {
    // you are hovering on the active one!
    clearStopLine();
  } else {
    var diff = begin - end;
    if (diff < 0) {
      diff = diff*-1;
    }
    if (begin < end) {
      // it will be lower
      $('.stop-dot-line.alive').css('height', (diff*60));
      $('.stop-dot-line.alive').css('top', 30);
    } else {
      // it will be higher
      //$('.stop-dot-line.alive').css('top', -30);
    }
  }
}

function clearStopLine() {
  $('.stop-dot-line.alive').removeAttr('style');
  $('.stop-dot-line.alive').css('height', '0');
}