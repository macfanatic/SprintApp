function animate_timer_bar() {
	var $red_bar = $("#red-bar");
	$red_bar.delay(2750).fadeIn(800, function() {
		$red_bar.delay(2750).fadeOut(800, animate_timer_bar);
	});
}

function start_clock_timer() {
	start_clock_timer.timer = window.setInterval(function() {
		
		if ( typeof start_clock_timer.ticker == 'undefined' ) {
			start_clock_timer.ticker = 0;
		}
		
		var $timer_text = $("#timer_text");
		var str = $timer_text.text();
		var pieces = str.split(":");
		var hours = Number(pieces[0]);
		var minutes = Number(pieces[1]);
		
		if ( ++start_clock_timer.ticker % 2 == 0 ) {
			
			$.rails.ajax({
				url: $timer_text.attr("data-update"),
				dataType: "script"
			});
			
			return;
			
		} 
		
		if ( minutes + 1 > 59 ) {
			hours += 1;
			minutes = 0;
		} else {
			minutes += 1;
		}
		
		var minutes_str = minutes + "";
		var hours_str = hours + "";
		
		if ( hours < 10 ) {
			hours = "0" + hours;
		}
		
		if ( minutes < 10 ) { 
			minutes = "0" + minutes;
		}
		
		$timer_text.text(hours + ":" + minutes);
		
	}, 60000);	// Every minute
}

function stop_clock_timer() {
	clearInterval(start_clock_timer.timer);
}

$(function() {
		
	if ( !$("#timer-bar").hasClass("hidden") ) {
		animate_timer_bar();
		start_clock_timer();
	}
	
	$("#timer-bar").click(function() {
		window.location.href = $("#timer-content > a").attr("href");
	});
		
});