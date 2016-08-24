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

$(document).ready(function() {
  $('.alerts').each(function() {
    if ($(this).hasClass('out_parent')) {
      $(this).parent().parent().before(this);
    }
    if ($(this).find('.notice').html().length > 0 || $(this).find('.alert').html().length > 0) {
      $(this).slideDown();
    }
  });
  
  $('.acordBtn').click(function() {
    var parent = $(this).closest('.route'),
      barHeight = 98,
      listQuant = parent.find('ul li').size();

    if (parent.hasClass('open')) {
      parent.find('.bar').height(79);
    } else {
      //barHeight = barHeight + ((listQuant-2)*38);
      //parent.find('.bar').height(barHeight);

      setInterval(function() {
        drawLine(parent.find('.origin'), parent.find('.desti'), parent.find('.bar'));
      });
    }
    dropAcord(parent, '.route');
  });

  $('input.delete').click(function(e) {
    var c = confirm("Are you sure you want to delete this? Click OK to continue.");
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
        $label   = $('.inputfile_label'),
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
                $('#profile_start_pic').hide();
              }
              $('#tempImg').attr('src', e.target.result).slideDown();
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
});


function dropAcord(element, eleClass) {
  if (element.hasClass('open')) {
      element.removeClass('open');
      element.find('.acord').slideUp(function(){
        clearInterval();
      });
    } else {      
      $(eleClass).each(function(){
        $(this).removeClass('open').find('.acord').slideUp(function(){
        clearInterval();
      });
      }).promise().done( function(){
        element.find('.acord').first().slideDown(function(){
        clearInterval();
      });
        //console.log(element.html());
      });
      element.addClass('open');
    }
}


function lineDistance(x, y, x0, y0){
    return Math.sqrt((x -= x0) * x + (y -= y0) * y);
};

function drawLine(a, b, line) {
  var pointA = $(a).offset();
  var pointB = $(b).offset();
  var distance = lineDistance(pointA.left, pointA.top, pointB.left, pointB.top);

  // Set Width
  $(line).css('height', distance + 'px');                  
}


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
