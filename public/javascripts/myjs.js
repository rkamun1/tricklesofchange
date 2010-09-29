$(document).ready(function() {
	//Select all anchor tag with rel set to tooltip
	$('.tooltip').mouseover(function(e) {		
		//Grab the title attribute's value and assign it to a variable
		var tip = $(this).attr('title');			
		//Remove the title attribute's to avoid the native tooltip from the browser
		$(this).attr('title','');		
		//Append the tooltip template and its value
		$(this).parent().append('<div id="tooltip" class="round"><div class="tipHeader"></div><div class="tipBody">' + tip + '</div><div class="tipFooter"></div></div>');						
		//Show the tooltip with fadeIn effect
		$('#tooltip').fadeTo('10',0.7);
		
	}).mousemove(function(e) {	
		//Keep changing the X and Y axis for the tooltip, thus, the tooltip move along with the mouse
		$('#tooltip').css('top', e.pageY + 10 );
		$('#tooltip').css('left', e.pageX + 20 );		
	}).mouseout(function() {	
		//Put back the title attribute's value
		$(this).attr('title',$('.tipBody').html());	
		//Remove the appended tooltip template
		$(this).parent().children('div#tooltip').remove();		
	});
});
