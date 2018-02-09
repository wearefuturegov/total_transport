$.fn.bookingHome = function() {
    
  if (this.length === 0) { return false; }
  
  var $wrapper = $(this);
  
  $.get('places.json', function(data) {
    $wrapper.data('places', data);
    $wrapper.find('.wrapper').removeClass('hidden');
    $wrapper.find('#loader').addClass('hidden');
    
    var enableTo = function(slug) {
      var toOptions = options;
      $('#from').data('slug', slug);
      toOptions.list.onChooseEvent = chosenTo;
      $('#to').easyAutocomplete(toOptions);
    }
    
    var chosenFrom = function() {
      var chosenItem = $("#from").getSelectedItemData();
      $('#from').data('placename', chosenItem.name);
      $('#from_result').addClass('hidden');
      $('#from_result').attr('hidden', true);
          
      if (chosenItem.route_count > 0) {
        enableTo(chosenItem.slug);
        $('#to').removeAttr('disabled');
      } else {
        var placename = $('#from').data('placename');
        $('#from_result #place').html(placename);
        $('#from_result').removeClass('hidden');
        $('#from_result').attr('hidden', false);
        $('#to').attr('disabled', 'true');
        $('#to').val('');
        $('#results').hide();
        $('#booking_submit').hide();
        $.post({
          url: '/log_entry/?from=' + chosenItem.name
        });
      }
    }
    
    var chosenTo = function() {
      var chosenItem = $("#to").getSelectedItemData();
      var url = '/journeys/' + $('#from').data('slug') + '/' + chosenItem.slug;

      $('#to').data('placename', chosenItem.name);
      $('#to_result').empty();
      
      $('#booking_submit').hide();
      
      $.get({
        url: url,
        dataType: 'script'
      });
      
      $('#results').show();
    }
      
    var options = {
      data: $wrapper.data('places'),
      getValue: "name",
      list: {
        onChooseEvent: chosenFrom,
        match: {
          enabled: true
        }
      },
      theme: 'square'
    };
      
    $wrapper.find('#from').easyAutocomplete(options);
    
    $wrapper.find('#booking_submit').click(function(e) {
      if ($wrapper.find('#from').val() == '') {
        $wrapper.find('.from input').addClass('required')
        $wrapper.find('.from .required-text').show()
      }
      
      if ($wrapper.find('#to').val() == '') {
        $wrapper.find('.to input').addClass('required')
        $wrapper.find('.to .required-text').show()
      }

      e.preventDefault();
    })
    
    $wrapper.find('#from, #to').on('keyup', function() {
      $wrapper.find('.from input').removeClass('required')
      $wrapper.find('.from .required-text').hide()
      $wrapper.find('.to input').removeClass('required')
      $wrapper.find('.to .required-text').hide()
    })
    
  });
  
}
