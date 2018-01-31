$.fn.bookingHome = function() {
    
  if (this.length === 0) { return false; }
  
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
        
    if (chosenItem.routes.length > 0) {
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
    
    $.get({
      url: url,
      dataType: 'script'
    });
    
    $('#results').show();
  }
  
  var options = {
    url: function(place) {
      return '/places.json?query=' + place
    },
    getValue: "name",
    list: {
      onChooseEvent: chosenFrom
    },
    theme: 'square'
  };
  
  $(this).find('#from').easyAutocomplete(options);
  
}
