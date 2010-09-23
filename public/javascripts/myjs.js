$(document).ready(function() {
    $('.hdr').hover(
      function () {
        $(this).addClass("hover");
      },
      function () {
        $(this).removeClass("hover");
      }
    );
});
