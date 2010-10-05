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
		$('#tooltip').fadeTo('10',0.9);
		
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
	
	$('.popup').click(function(e) {
	    //Grab the title attribute's value and assign it to a variable
		var dataheader = $(this).attr('data-header');		
		var databody = 	$(this).attr('data-info')
		//Append the popup template and its value
		$(this).parent().append('<div id="popup" class="round" title="How ' + dataheader + ' work"><div class="popupBody">' + databody + '</div><div class="tipFooter"></div></div>');		
	
	    $('#popup').dialog({  
			    modal: true,
			    width: 500
        });
	})
	
	$('#reset').click(function(e) {		
	e.preventDefault();
	   $(this).append('<div id="dialog-confirm" title="Reset your account information?"><p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"/></span>This will reset your stash and account accrued amounts to zero. You cannot undo this. Are you sure you want to proceed?</p>')
	    
		$( "#dialog-confirm" ).dialog({
			modal: true,
			buttons: {
				"Reset account": function() {
					$( this ).dialog( "close" );
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	});

});
