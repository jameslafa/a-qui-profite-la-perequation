$ ->
    if $("#intro").length > 0
        $(".mentions a").click (event) ->
            event.preventDefault()
            $(".mentions-popup").addClass("show")
            return false

        $(".mentions-popup .close").click (event) ->
            event.preventDefault()
            $(".mentions-popup").removeClass("show")
            return false

        $(document).keyup (event) ->
            if event.keyCode == 27
                $(".mentions-popup").removeClass("show")

        $(".mentions-popup").height $(document).height()