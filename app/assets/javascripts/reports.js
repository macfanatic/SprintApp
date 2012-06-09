$(function() {
	
	$("#project_chooser").change(function(e) {
		$.post("/ticket_report/tickets.js", {project_id: $(this).val()});
	});
	
	$("#toggle_employees").click(function(e) {
		$("#employee_listing :checkbox:not(#toggle_employees)").attr('checked', $(this).attr('checked') == 'checked');
	});
	
});