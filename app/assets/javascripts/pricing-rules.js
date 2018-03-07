$.fn.pricingRules = function() {
    
  if (this.length === 0) { return false; }
  
  var changeStages = function() {
    var stages = {};
    $('#stages_wrapper .wrapper').each(function() {
      var from = $(this).find('.rule_to').val()
      var price = $(this).find('.price').val()
      stages[from] = price;
    });
    
    $('#pricing_rule_stages').attr('value', JSON.stringify(stages));
  }
  
  $(this).find('#pricing_rule_child_fare_rule').on('change', function() {
    var ruleType = $(this).val();
    $('#multiplier, #flat_rate').addClass('hidden');
    $('#' + ruleType).removeClass('hidden');
  })
    
  $(this).find('#pricing_rule_rule_type').on('change', function() {
    $('#per_mile').addClass('hidden');
    $('#stages').addClass('hidden');
    
    if ($(this).val() == 'per_mile') {
      $('#per_mile').removeClass('hidden');
    } else {
      $('#stages').removeClass('hidden');
    }
  })
    
  $(this).find('#add-stage').click(function(e) {
    var $stage = $($(this).data('content'));
    var id = 'stage_' + Date.now();
    var lastMileage = $('.rule_to').last().val() || 0;
    
    $stage.find('.wrapper').attr('id', id);
    $stage.find('.remove').attr('data-parent-id', id);
    $stage.find('.rule_from').attr('value', lastMileage);
    
    $stage.find('input').each(function() {
      var oldID = $(this).attr('id');
      $(this).attr('id', oldID + '_' + id);
    });
    
    $stage.find('label').each(function() {
      var oldID = $(this).attr('for');
      $(this).attr('for', oldID + '_' + id);
    });
        
    $('#stages_wrapper').append($stage.html());
    e.preventDefault();
  })
  
  $(this).on('click', '#stages_wrapper .remove', function(e) {
    var id = $(this).data('parent-id');
    $('#' + id).remove();
    changeStages();
    e.preventDefault();
  })
  
  $(this).on('change', '#stages_wrapper input', changeStages);
  
  changeStages();
}
