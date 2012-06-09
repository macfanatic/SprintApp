jQuery(function($) {
	
	// If fullscreen mode
	if ( ("standalone") in window.navigator ) {
		
		// Prompt user to use in full screen mode, if not already
		if ( !window.navigator.standalone ) {
			$("#ipad-warning-bar").slideDown('slow');
		}
		
		// Handle all clicks in fullscreen mode (don't want to take you outside of the fullscreen mode)
		$("a").click(function(e) {
			e.preventDefault();
			window.location = $(e.target).attr('href');
		});
	
	}
	
});