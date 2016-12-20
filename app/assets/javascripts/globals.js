$(window).load(function() {

  $('a[href*="#"]:not([href="#"])').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
      if (target.length) {
        $('html, body').animate({
          scrollTop: target.offset().top - 20
        }, 1000);
        return false;
      }
    }
  });
});

$(window).resize(function() {
  $('.pop-up-box').css('margin-left', ($('.pop-up-box').width()/2)*-1).css('margin-top', ($('.pop-up-box').height()/2)*-1);
});

$(document).ready(function() {
  if ($('#returnTab').length) {
    if (localStorage.returnJourney == "true") {
      $('.return-ticket').each(function() {
        $(this).removeClass('hidden');
      });
      $('.single-ticket').each(function() {
        $(this).addClass('hidden');
      });
      $('#returnTab').addClass('selected');
      $('#singleTab').removeClass('selected');
    } else {
      $('.single-ticket').each(function() {
        $(this).removeClass('hidden');
      });
      $('.return-ticket').each(function() {
        $(this).addClass('hidden');
      });
      $('#singleTab').addClass('selected');
      $('#returnTab').removeClass('selected');
    }
  }
  if ($('.pop-up').length) {
    $('.pop-up').on('click', function(e) {
      if (e.target !== this)
        return;
      closePopup();
    });
    $('.pop-up-close').click(function() {
      closePopup();
    });
    $('#popup-continue').click(function() {
      closePopup();
    });
    $('#cancel-booking').click(function() {
      showPopup();
    });
  }

  if ($('.alerts').length) {
    $('.alerts').slideDown();
  }


  $("form").submit(function() {
    $(this).submit(function() {
        return false;
    });
    return true;
  });

  $('.acordBtn').click(function() {
    var parent = $(this).closest('.route'),
      barHeight = 98,
      listQuant = parent.find('ul li').size();

    if (!parent.hasClass('reversed')) {
      var reverseParent = $('#' + parent.attr('id') + '-reversed');
    } else {
      var reverseParent = $('#' + parent.attr('id').replace('-reversed', ''));
    }


    sortAcord(parent);
    if (reverseParent) {
      sortAcord(reverseParent);
    }
    dropAcord(parent, '.route', reverseParent);
  });

  //NEED TO FIX THIS - HACK TO MOVE CONTENT INSIDE THE TOP SECTION
  if ($('#move-to-top').length) {
    var content = $('#move-to-top').contents();
    $('.top-sec .inner').append(content);
  }

  $('input.delete').click(function(e) {
    var c = confirm("Are you sure you want to cancel this? Click OK to continue.");
    return c;
  });

  $('input.name_validation').click(function(e) {
    if ($('#stop_name').val() == '') {
      alert('You need to add a name');
      return false;
    } else {
      if ($('#stop_latitude').length) {
        if ($('#stop_latitude').val() == '') {
          alert('You need to draw a stop area');
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    }
  });

  if ($('.inputfile').length) {
    $( '.inputfile' ).each( function(){
      var $input   = $( this ),
        $label   = $('.inputfile-label'),
        labelVal = $label.html();
      $input.on( 'change', function( e ) {
        var files = e.target.files;

        for (var i = 0, f; f = files[i]; i++) {
          if (!f.type.match('image.*')) {
            continue;
          }
          var reader = new FileReader();
          reader.onload = (function(theFile) {
            return function(e) {
              if ($('#plaecholderProfile').length) {
                $('#plaecholderProfile').hide();
              } else {
                $('#profile-start-pic').hide();
              }
              $('#tempImg').attr('src', e.target.result).slideDown(function() {
                if ($('#tempImg').height() < $('#theFace').height()) {
                  $('#tempImg').height($('#theFace').height()).css('max-width', 'none');
                }
              });
            };
          })(f);
          reader.readAsDataURL(f);
        }

        var fileName = e.target.value.split( '\\' ).pop();

        if( fileName ) {
          $label.find('span').html( fileName );
          $label.addClass('active');

        } else {
          $label.html( labelVal );
          $lavel.removeClass('active');
        }
      });

      // Firefox bug fix
      $input
      .on( 'focus', function(){ $input.addClass( 'has-focus' ); })
      .on( 'blur', function(){ $input.removeClass( 'has-focus' ); });
    });
  }

  $('#returnTab').click(function() {
    localStorage.setItem("returnJourney", "true");
  });
  $('#singleTab').click(function() {
    localStorage.setItem("returnJourney", "false");
    clearRadios();
  });

  $('.tab').click(function() {
    if (!$(this).hasClass('selected')) {
      var parent = $(this).parent();
      parent.children('.tab').each(function() {
        if ($(this).hasClass('selected')) {
          $(this).removeClass('selected');
        }
      });
      // unique stuff for choose return journey
      if (!$(this).hasClass('selected')) {
        if ($(this).hasClass('single-tab')) {
          $('.return-ticket').toggleClass('hidden');
          $('.single-ticket').toggleClass('hidden');
          $('#hideReturn').slideUp().addClass('hidden');
          if ($('#hideReturn').length) {
            $('.single-journey.selected').removeClass('selected');
            $('.return-btn').addClass('disabled').attr('disabled', true);
          }
        } else if ($(this).hasClass('return-tab')) {
          $('.return-ticket').toggleClass('hidden');
          $('.single-ticket').toggleClass('hidden');
        }
      }

      $(this).toggleClass('selected');
    }
  });
});

function drawLine(a, b, line) {
  var pointA = $(a).offset();
  var pointB = $(b).offset();
  var distance = lineDistance(pointA.left, pointA.top, pointB.left, pointB.top);

  // Set Width
  $(line).css('height', distance + 'px');
}

function sortAcord(parentObj) {
  if (parentObj.hasClass('open')) {
    parentObj.find('.bar').height(79);
  } else {
    setInterval(function() {
      drawLine(parentObj.find('.origin'), parentObj.find('.desti'), parentObj.find('.bar'));
    });
  }
}

function dropAcord(element, eleClass, reverse) {
  if (element.hasClass('open')) {
    element.removeClass('open');
    element.find('.acord').slideUp(function(){
      clearInterval();
    });
    if (reverse) {
      reverse.removeClass('open');
      reverse.find('.acord').slideUp(function(){
        clearInterval();
      });
    }
  } else {
    $(eleClass).each(function(){
      $(this).removeClass('open').find('.acord').slideUp(function(){
      clearInterval();
    });
    }).promise().done( function(){
      element.find('.acord').first().slideDown(function(){
        clearInterval();
      });
      if (reverse) {
        reverse.find('.acord').first().slideDown(function(){
          clearInterval();
        });
      }
    });
    element.addClass('open');
    if (reverse) {
      reverse.addClass('open');
    }
  }
}

function lineDistance(x, y, x0, y0){
  return Math.sqrt((x -= x0) * x + (y -= y0) * y);
};


function alertRails(alertTxt, inputObj) {
  if ($('#alerts').is(':visible')) {
    $('#alerts').slideUp(function() {
      $('#alerts').find('.notice').html(alertTxt);
      $('#alerts').slideDown();
    });
  } else {
    $('#alerts').find('.notice').html(alertTxt);
    $('#alerts').slideDown();
  }
  if (inputObj) {
    inputObj.focus().addClass('incorrect');
  }
}

function checkPassengers(num) {
  $('.single-journey').each(function() {
    if (num > $(this).data('seats')) {
      $(this).addClass('unavailable');
      if ($(this).hasClass('selected')) {
        $(this).removeClass('selected');
        $('.continue-btn').slideDown().removeClass('hidden');
        $('input[type="submit"]').addClass('disabled').attr('disabled', true)
      }
    } else {
      $(this).removeClass('unavailable');
    }
  });
}

function clearRadios() {
  $('.journey-select').each(function() {
    $(this).prop('checked', false);
  });
}

function closePopup() {
  $('.pop-up').fadeOut(150);
}
function showPopup() {
  $('.pop-up').fadeIn(150);
  $('.pop-up-box').css('margin-left', ($('.pop-up-box').width()/2)*-1).css('margin-top', ($('.pop-up-box').height()/2)*-1);
}
