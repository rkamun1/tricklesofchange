$(document).ready(function() {
 $(function (){  
  $('#spending_spending_date').attr("onFocus","javascript:blur();");
  $('#spending_spending_date').datepicker({ minDate: -2, maxDate: 0, dateFormat: 'd M, yy' });

 });  
 
 //for the profile stats tabs
 $(function() {
 
		$('#thenumbers').tabs();
	});

});
