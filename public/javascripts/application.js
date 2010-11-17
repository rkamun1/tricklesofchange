$(document).ready(function() {
    $(function (){
      $('#account_maturity_date').attr("onFocus","javascript:blur();");
      $('#account_maturity_date').datepicker({ minDate: 1, dateFormat: 'MM d, yy' });
    });
    
    $(function (){

      $('#spending_spending_date').attr("onFocus","javascript:blur();");
      $('#spending_spending_date').datepicker({ minDate: -30, maxDate:0, dateFormat: 'MM d, yy' });
    });

    //for the profile stats tabs
    $(function() {
        $('#thenumbers').tabs();
    });

    $(function() {
        var s = window.location.pathname;
        if(s == '/' || s.indexOf("/signup") === 0 || s.indexOf("/forgot_password") === 0 || s.indexOf("/join") === 0 || s.indexOf("//sessions"))
        {
            $('#signupbtn').hide();
        }
    });
});


