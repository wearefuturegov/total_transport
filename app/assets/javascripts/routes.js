$(document).ready(function() {
	$('.route .acordBtn').click(function() {
		var parent = $(this).parent('.route');
		if (parent.hasClass('open')) {
			parent.removeClass('open');
			parent.find('.acord').slideUp();
		} else {
			
			$('.route').each(function(){
				$(this).removeClass('open').find('.acord').slideUp();
			}).promise().done( function(){
				parent.find('.acord').slideDown();
			});
			parent.addClass('open');
		}
	});
});