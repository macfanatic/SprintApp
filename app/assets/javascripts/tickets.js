$(function() {
	
	$("a.edit-ticket-history").live('click', function(e) {
		
		var $this = $(this);
		e.preventDefault();
		
		if ( Number($this.attr("data-time")) == 0 ) {
			window.alert("You cannot add time to a comment without time.");
			return;
		}
		
		var newTime = window.prompt("Please provide an updated time greater than 0.01", $this.attr("data-time"));
		if ( newTime === null ) return;
		
		if ( isNaN(newTime) ) {
			
			window.alert("'" + newTime + "' is not a valid number. Please try again.");
			
		} else {
			
			$.rails.ajax({
				url: $this.attr("href"),
				data: {
					id: $this.attr("data-id"),
					time: newTime
				},
				type: "POST",
				dataType: "script"
			});
		}
		
	});
	
});