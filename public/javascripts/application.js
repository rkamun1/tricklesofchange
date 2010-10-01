$(document).ready(function() {
    $(function (){
      $('#account_maturity_date').attr("onFocus","javascript:blur();");
      $('#account_maturity_date').datepicker({ minDate: 1, dateFormat: 'MM d, yy' });
    });

    //for the profile stats tabs
    $(function() {
        $('#thenumbers').tabs();
    });
});


