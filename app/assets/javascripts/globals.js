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
