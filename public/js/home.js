// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    if ($("#intro").length > 0) {
      $(".mentions a").click(function(event) {
        event.preventDefault();
        $(".mentions-popup").addClass("show");
        return false;
      });
      $(".mentions-popup .close").click(function(event) {
        event.preventDefault();
        $(".mentions-popup").removeClass("show");
        return false;
      });
      $(document).keyup(function(event) {
        if (event.keyCode === 27) {
          return $(".mentions-popup").removeClass("show");
        }
      });
      return $(".mentions-popup").height($(document).height());
    }
  });

}).call(this);