$(document).ready(function() {	
	// Remove overlay on window load event
    $(window).load(function(){
        $('.doc-loader').fadeOut('slow');
    });
});