$(document).ready(function() {
 $(function (){  
  $('#spending_spending_date').attr("onFocus","javascript:blur();");
  $('#spending_spending_date').datepicker({ minDate: -2, maxDate: 0, dateFormat: 'd M, yy' });

 });  
 
  $('a.popup').click(function() {
    $('<div />').appendTo('body').dialog({
      title: $(this).attr('title'),
      modal: true
    }).load($(this).attr('href') + ' form', function() {
      $form = $(this).find('form')
      $form.find(':text:first').focus();
      $btn = $form.find(':submit');
      var txt = $btn.val();
      $btn.remove();
      var buttons = {};
      buttons[txt] = function() {
        $.ajax({
          type: $form.attr('method'),
          url: $form.attr('action'),
          data: $form.serialize(),
          dataType: 'script',
          complete: function(xhr, status) {
            $form.append('<div class="'+status+'">'+xhr.responseText+'</div>');
            
            return false;
          }
        });
      };
      $(this).dialog('option','buttons', buttons );
    });
    return false;
  });
});
