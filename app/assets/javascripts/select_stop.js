// ToDo: change slideUp / sildeDown to a CSS animation

$(document).ready(function() {
  if ($("#passenger-stop-select").length) { //  CONDITIONAL STATEMENT SO IT ONLY WORKS ON ONE PAGE
    var activeDots = 0;
    var numOfStops = $('.stop').length;
    var stopNumber = 0;
    var pkupTxt = 'Choose Pick Up Area';
    var drpfTxt = 'Choose Drop Off Area';
    var cnfmTxt = 'Confirm Route';
    $('.stop').last().addClass('lastChild');
    sortLineHeight(0);

    // If a stop is clicked
    $('.stop').click(function() {
      if (activeDots == 2 && $(this).hasClass('firstStop')) {
        // ensure that the first one cannot be clicked if there are two clicked
        event.stopPropagation();
      } else if ($(this).hasClass('lastChild')) {
        // ensure that the last once cannot be clicked
        event.stopPropagation();
      } else {
        // If it has already been clicked - Revert
        if ($(this).hasClass('active')) {
          // lower the current global of active dots
          activeDots--;
          // remove its active class
          $(this).removeClass('active').removeClass('chosenLastStop');
          // remove the alive class from its child
          $(this).find('.stop-dot-line').removeClass('alive');
          $(this).find('.stop-dot-line').removeAttr('style');
          if (activeDots == 1) {
            // If there is still another dot active move the global trackers onto that stop
            $('h1').html(drpfTxt);
            clearStopLine();
            stopNumber = $('.stop.active').attr('id');
            $('.stop.active').find('.stop-dot-line').addClass('alive');
            // reveal all stops above
            var revealNum = $('.stop:not([style*="display: none"])').length;
            for (var i = numOfStops; i >= (parseInt($(this).attr('id')) + 1); i--) {
              $('#'+i).slideDown();
              revealNum++;
            }
            sortLineHeight(revealNum);
            // remove sub stop class from everything
            $('.stop').each(function(){
              $(this).removeClass('subStop');
            });
            $('#confirmation').slideUp(250);
          } else {
            // if there is no other stop remaining active reset to the start
            $('h1').html(pkupTxt);
            $('.firstStop').removeClass('firstStop');
            clearStopLine();
            stopNumber = 0;
            $('.lastChildOff').addClass('lastChild');
            $('.lastChildOff').removeClass('lastChildOff');
            // reveal any hidden stops
            $('.stop').each(function(){
              $(this).slideDown();
            });
            sortLineHeight(0);
          }
        } else {
          // if it is not active - Make active
          if (activeDots < 2) {
            drawStopLine(stopNumber, parseInt($(this).attr('id')));
            // Only allow this if no more than 2 dots are active
            activeDots++;
            $('.lastChild').addClass('lastChildOff');
            $('.lastChild').removeClass('lastChild');
            $(this).addClass('active');
            // if this is the last stop add last stop class
            if (activeDots == 2) {
              $(this).addClass('chosenLastStop');
            }
            
            if (activeDots == 1) {
              // if its the first dot store the globals and set title
              $('h1').html(drpfTxt);
              $(this).find('.stop-dot-line').addClass('alive');
              $(this).addClass('firstStop');
              // hide any stops above the clicked dot
              var hiddenNum = 0;
              for (var i = (parseInt($(this).attr('id')) - 1); i >= 0; i--) {
                $('#'+i).slideUp();
                hiddenNum++;
              }
              sortLineHeight(hiddenNum-1);

              stopNumber = parseInt($(this).attr('id'));
            } else if(activeDots == 2) {
              // both stops have been chosen
              $('h1').html(cnfmTxt);
              setTimeout(function(){
                $('#confirmation').slideDown(500);
              }, 100);
              setStopIDs();
              // hide any stop below the second stop clicked
              var hiddenNum = 0;
              for (var i = numOfStops; i >= (parseInt($(this).attr('id')) + 1); i--) {
                $('#'+i).slideUp();
                hiddenNum++;
              }
              sortLineHeight(hiddenNum);

              // add class to all sub stops 
              setTimeout(function(){
                $('.stop').each(function(){
                  if (!$(this).hasClass('active')) {
                    $(this).addClass('subStop');
                  }
                });
              }, 100);
            }
          }
        }
      }
    });



    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
      //IF MOBILE IT DOES NOT DO HOVER EFFECTS

    } else {
      $('.stop').hover(function() {
        
        if ($(".firstStop")[0]) { 
          var stopID = $(this).attr('id');
          var startID = $(".firstStop").attr('id');
          var stopsBetween = ($(this).attr('id') - $(".firstStop").attr('id'))-1;
          if (stopsBetween > 0) {
            for (var i = startID; i <= (stopID-1); i++) {
              $('#'+i).addClass('tempHover');
            }
            console.log('stopid = ' +stopID +' startID = '+ startID + ' between = ' + stopsBetween);
          }
        } else {

        }
        // hover functions for drawing the red line and adding classes
        // check if its not the last stop
        if ($(this).hasClass('lastChild')) {
          // it is the last stop
          $(this).addClass('lastHover');
        } else {
          // if on hover there is only one dot draw a line from the first dot to the current hover
          if (stopNumber != 0 && activeDots == 1) {
            var potentialStop = parseInt($(this).attr('id'));
            drawStopLine(stopNumber, potentialStop);
            //If not first stop add secondary hover class for colouring
            if (!$(this).hasClass('firstStop')) {
              $(this).addClass('hoverSecondary');
            }
          }
          if (activeDots == 2 && $(this).hasClass('firstStop')) {
          // remove hover effect from the first stop if two stops are clicked
            $(this).css({'cursor' :"default"});
          } else {
            // only add the hover state if there is less than 2 dots active
            if (activeDots >= 2) {
              if ($(this).hasClass('active')) {
                $(this).addClass('hover');
              }
            } else {
              $(this).addClass('hover');
            }
          }
        }

      // reset this on mouse out
      }, function() {
          $(this).css({'cursor' :"pointer"});
          $(this).removeClass('hover');
          $(this).removeClass('lastHover');
          $(this).removeClass('hoverSecondary');
          $('.stop').each(function() {
            $(this).removeClass('tempHover');
          })
          //clearStopLine();
      });
    }
    function sortLineHeight(lossNumber) {
      //var newNumOfStops = $('.stop:not([style*="display: none"])').length;
      var currentNum = $('.stop:not([style*="display: none"])').length;
      if (currentNum == lossNumber) {
        $('#main-line').height(((currentNum-2)*64)+50);
      } else {
        var newNumOfStops = currentNum - lossNumber;
        $('#main-line').height(((newNumOfStops-2)*64)+50);
      }
    }


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
          $('.stop-dot-line.alive').css('top', 35);
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
  }

  function setStopIDs() {
    var pickup_stop_id = $($('.stop.active')[0]).data('stop-id');
    var dropoff_stop_id = $($('.stop.active')[1]).data('stop-id');
    $('#booking_pickup_stop_id').val(pickup_stop_id);
    $('#booking_dropoff_stop_id').val(dropoff_stop_id);
  }
});