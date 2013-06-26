class Perequations
    constructor: () ->
        # Define application settings
        @appSettings =
            applicationRootUrl : window.appUrl || window.location.protocol + '//' + window.location.hostname #"http://perequations.dev"
            numberFormat: "# ##0."

        # Define static graph settings
        @graphSettings =
            width : $(".data").width()
            height : $(".data").height()
            layoutGravity : -0.01
            damper : 0.07
            animationSpeed : 1000
            circleRange :
                min: 20
                max: 80
            circleOpacity: 0.8

        # Define dynamic graph settings
        @graphSettings["centers"] =
            receive:
                x : Math.round(2.5 * @graphSettings.width / 10)
                y : Math.round(@graphSettings.height /2)
            neutral:
                x : Math.round(@graphSettings.width / 2)
                y : Math.round(@graphSettings.height /2)
            give:
                x : Math.round(7.5 * @graphSettings.width / 10)
                y : Math.round(@graphSettings.height /2)

        @graphSettings["colors"] =
            give: "#DD003F"
            neutral: "#F7C63C"
            receive: "#86BC31"

        # Initialize history.js
        @history = window.History

        # Define instance variables
        # SVG visualization
        @vis = null
        # List of nodes already added to the visualization
        @nodes = []
        # Force layout
        @force = null
        # Scale function to define circle size
        @circleSizeScale = null
        # Scale function to define circle position on richesse view
        @circleRichesseRevenuPositionScale = null
        @circleRichessePotentielPositionScale = null
        @axeExtremeValues =
            revenu:
                min: 0
                max: 0
            potentiel:
                min: 0
                max: 0
        # Current data
        @currentState = null
        @rollbackState = null

        # Update page components
        this.updatePageComponents()

        # Bind events
        this.initEvents()

        # Initialize the force layout
        this.start()

        # Create the visualization
        this.createVis()



    #
    # Bind application events
    #
    initEvents: () =>
        that = this

        # Catch unautorized ajax error, and display modal
        $(document).ajaxError((event, jqXHR, ajaxSettings, thrownError) =>
            if jqXHR.status == 403
                $('#unautorized').modal('show')
        )

        $(document).ajaxStart () ->
            $("body").addClass('busy')

        $(document).ajaxStop () ->
            $("body").removeClass('busy')

        # Handle perequation radio button click
        $('.perequation a').on('click', (event) ->
            event.preventDefault()
            # Get the selected perequation and update the currentStage with it
            if $(this).hasClass("disabled")
               return false
            else
                that.generateNewHistoryState({perequation: $(this).attr("value"), change: "perequation"})
        )

        $('.view_selector button').on('click', (event) ->
            event.preventDefault()
            # Get the selected view and update the currentStage with it
            that.generateNewHistoryState({view: $(this).data("view"), change: "view"})
        )

        $('.richesse_selector button').on('click', (event) ->
            event.preventDefault()
            # Get the selected view and update the currentStage with it
            if not $(this).hasClass("disabled")
                that.generateNewHistoryState({richesse: $(this).data("richesse"), change: "view"})
            return false
        )

        $(document).on('click', '.data a, nav.perequation_level a.change_level', (event) ->
            event.preventDefault()
            if not $(this).hasClass("disabled")
                # Push a new state based on link url
                that.pushNewStateFromUrl($(this).attr("href"))
            return false
        )

        # Handle unauthorized model button click
        $('#unautorized .rollback').on('click', (event) =>
            ga('send', 'event', 'subscription', 'no')
            # Rollback to the previous stage
            this.generateNewHistoryState(@rollbackState, true)
        )
        $('#unautorized .identify').on('click', (event) =>
            currentUrl = window.location.href
            if $(this).hasClass("register")
                ga('send', 'event', 'subscription', 'yes')
                ga('send', 'event', 'subscription-from', currentUrl)
            else
                ga('send', 'event', 'subscription', 'identify')
            window.location.href = encodeURI("#{@appSettings.applicationRootUrl}/identifier?url=#{currentUrl}")
        )


        # Update vis on data push
        History.Adapter.bind window, "statechange", =>
            currentState = this.getCurrentState()

            if currentState.change == "perequation"
                # Update value depending the choosen perequation
                that.updateNodeValue()
                # Update circle size and color with new data
                this.updateCircleShape()
                # Update every node url
                this.updateNodeUrl()
                # Relaunch the force layout to update the centersc
                @force.start()
            else if currentState.change == "view"
                # Update every node url
                this.updateNodeUrl()
                # Relaunch force layout to update centers
                @force.start()
            else if currentState.change == "level"
                # Update the all vis while getting new data
                that.updateVis()

            this.updatePreviousLevelUrl()
            this.updatePageComponents()


    #
    # Define the force layout
    #
    start: () =>
        # Start force layout for every node
        @force = d3.layout.force()
            .nodes(@nodes)
            .size([@graphSettings.width, @graphSettings.height])

        # Define physics for the force layout
        @force.gravity(@graphSettings.layoutGravity)
            .charge(this.charge)
            .friction(0.9)
            .on "tick", (e) =>
                # On every tick, every circle are moved to their appropriate center
                @vis.selectAll("g.node").each(this.moveTowardsCenter(e.alpha))
                    .attr("transform", (d) => "translate(" + d.x + "," + d.y + ")")



    #
    # Create the SVG visualization container
    #
    createVis: () =>
        # Create the SVG container
        @vis = d3.select(".data")
                            .append("svg")
                            .attr("width", @graphSettings.width)
                            .attr("height", @graphSettings.height)

        @vis.append("svg:defs").selectAll("marker")
            .data(["endArrow"])
            .enter().append("svg:marker")
                .attr("id", String)
                .attr("viewBox", "0 -5 10 10")
                .attr("refX", 10)
                .attr("refY", 0)
                .attr("markerWidth", 15)
                .attr("markerHeight", 15)
                .attr("orient", "auto")
                .attr("fill", "#555")
                .append("svg:path")
                    .attr("d", "M0,-5L10,0L0,5")

        @vis.append("g")
            .attr("class", "richesse-line")
            .attr("opacity", if @currentState.view == "richesse" then 1 else 0)
            .append("svg:line")
                .attr("x1", 0)
                .attr("y1", Math.round(@graphSettings.height / 2))
                .attr("x2", @graphSettings.width)
                .attr("y2", Math.round(@graphSettings.height / 2))
                .style("stroke", "#555")
                .style("stroke-width", 1)
                .attr("marker-end", "url(#endArrow)")

        @vis.append("g")
            .attr("class", "min-value")
            .attr("opacity", if @currentState.view == "richesse" then 1 else 0)
            .append("text")
                .attr("x", 0)
                .attr("y", Math.round(@graphSettings.height / 2) + 30)
                .attr("fill", "#555")

        @vis.append("g")
            .attr("class", "max-value")
            .attr("opacity", if @currentState.view == "richesse" then 1 else 0)
            .append("text")
                .attr("x", @graphSettings.width)
                .attr("y", Math.round(@graphSettings.height / 2) + 30)
                .attr("fill", "#555")
                .attr("text-anchor", "end")

        # Add legend
        _.each _.keys(@graphSettings["colors"]),  (key) =>
            $(".legende .color.#{key}").css("background-color", @graphSettings["colors"][key])

        # Add tooltip
        d3.select(".data").append("div")
                            .attr("class", "circle-tooltip")
        # Update Visualization to display the first bubbles
        this.updateVis()



    #
    # Update nodes and then create circles
    #
    updateVis: () =>
        that = this

        # Update nodes
        this.updateNodes(() =>
            # Select every groups depending the nodes
            groups = @vis.selectAll("g.node")
                            .remove()
                            .data(@nodes, (d) => @currentState.type + "_#{d.id}")

            groups.enter()
                    .append("g")
                    .attr("class", "node")
                    .attr("id", (d) => d.id)
                    .attr("x", (d) => d.x)
                    .attr("y", (d) => d.y)


            # Add circles and text to links
            circles = groups.append("circle")
                            .attr("r", 0)
                            .attr("fill", (d) => this.getNodeColor(d))
                            .attr("fill-opacity", @graphSettings.circleOpacity)
                            .attr("stroke-width", 1)
                            .attr("stroke", (d) => d3.rgb(this.getNodeColor(d)).darker())
                            .on("mouseover", (d) -> that.displayTooltip(d, this))
                            .on("mouseout", (d) -> that.hideTooltip(this))

            # Add the label to circle
            groups.append("a")
                    .attr("class", "change_level")
                    .attr("xlink:href", (d) => this.generateNewLevelUrl(d.levelId))
                    .attr("groupId", (d) => d.id)
                    .on("mouseover", (d) -> that.displayTooltip(d, this, true))
                    .on("mouseout", (d) -> that.hideTooltip(this))
                    .append("text")
                        .attr("text-anchor", "middle")
                        .attr("dy", ".35em")
                        .text((d) => d.code)


            groups.call(@force.drag);

            # Make new bubble grow from 0 to their regular radius
            circles.transition()
                    .duration(@graphSettings.animationSpeed)
                    .attr("r", (d) => return d.radius)

            if @currentState.richesse == "potentiel"
                d3.select("g.min-value text").text("#{this.numberFormat @axeExtremeValues.potentiel.min} €")
                d3.select("g.max-value text").text("#{this.numberFormat @axeExtremeValues.potentiel.max} €")
            else
                d3.select("g.min-value text").text("#{this.numberFormat @axeExtremeValues.revenu.min} €")
                d3.select("g.max-value text").text("#{this.numberFormat @axeExtremeValues.revenu.max} €")

            # Relaunch the force layout
            @force.start()
            this.hideTooltip()
        )



    #
    # Depending the current state, get new nodes data
    #
    updateNodes: (callback) =>
        # Get the current state
        currentState = this.getCurrentState()

        # Get the data depending to the current state
        this.getCurrentData(currentState, (data)=>

            # Clear the nodes array
            @nodes.length = 0

            # Store previous level
            currentState.departementId = null

            # Loop on data to update every nodes
            _.each(data, (element, index, list) =>
                node =
                    id: currentState.type + "_" + element.id
                    levelId: element.id
                    nom: element.nom
                    population: parseInt(element.population)
                    revenu:
                        value: parseInt(element.revenu_hab)
                        moyen: parseInt(element.revenu_hab_moyen)
                        rang: parseInt(element.revenu_hab_rang)
                    fpic:
                        value: parseInt(element.fpic_2012)
                        rang: parseInt(element.fpic_rang_2012)
                        hab: parseFloat(element.fpic_hab_2012).toFixed(2)
                        habRang: parseInt(element.fpic_hab_rang_2012)
                    total:
                        value: parseInt(element.total_2012)
                        rang: parseInt(element.total_rang_2012)
                        hab: parseFloat(element.total_hab_2012).toFixed(2)
                        habRang: parseInt(element.total_hab_rang_2012)

                if currentState.type == "france"
                    # Use region code
                    node.code = element.code

                    node.dmto =
                        value : parseInt(element.dmto_2012)
                        rang : parseInt(element.dmto_rang_2012)
                        hab: parseFloat(element.dmto_hab_2012).toFixed(2)
                        habRang: parseInt(element.dmto_hab_rang_2012)

                else if currentState.type == "regions"
                    # Use departement code
                    node.code = this.leadingZero(element.id)

                    node.potentielFiscal =
                        value: parseInt(element.potentiel_fiscal_hab)
                        moyen: parseInt(element.potentiel_fiscal_moyen)
                        rang: parseInt(element.potentiel_fiscal_rang)

                    node.dmto =
                        value : parseInt(element.dmto_2012)
                        rang : parseInt(element.dmto_rang_2012)
                        hab: parseFloat(element.dmto_hab_2012).toFixed(2)
                        habRang: parseInt(element.dmto_hab_rang_2012)

                else if currentState.type == "departements"
                    node.potentielFiscal =
                        value: parseInt(element.potentiel_fiscal_hab)
                        moyen: parseInt(element.potentiel_fiscal_hab_moyen)
                        rang: parseInt(element.potentiel_fiscal_hab_rang)

                    # Update previous level value
                    if not currentState.departementId
                        currentState.departementId = element.departement_id

                @nodes.push(node)
            )

            # Update the previous level url
            this.updatePreviousLevelUrl()

            # Update values for every nodes depending the state
            this.updateNodeValue()

            # call the callback
            callback()
        )



    #
    # Get the current state of the application using history api
    #
    getCurrentState: () =>
        # Get the current state
        historyState = @history.getState()

        # If the state is empty, it means this is the first launch of application. Let's initialize the state
        if $.isEmptyObject(historyState.data)
            currentState = this.extractStateFromUrl(window.location.href)
            if currentState
                return @currentState = currentState

            # If the url is not correct, we can't extract the state so we can't do anything else
            else
                return false

        # If the state is already define, let's just return it
        else
            return @currentState = historyState.data



    #
    # Get the current data depending the state
    #
    getCurrentData: (state, callback) =>
        # To get the right data, we need first to know the current state of the application
        stateData = @currentState

        # Depending the state, we'll are going to construct the request parameters
        dataUriParameters = null

        if stateData
            switch stateData.type
                when "france"
                    dataUriParameters =
                        niveau : "regions"
                        collectivite : "all"
                when "regions"
                    dataUriParameters =
                        niveau : "departements/region"
                        collectivite : stateData.id
                when "departements"
                    dataUriParameters =
                        niveau : "intercos/departement"
                        collectivite : stateData.id

            $.ajax(
                url: @appSettings.applicationRootUrl + "/api/" + dataUriParameters.niveau + "/" + dataUriParameters.collectivite
                dataType: 'json'
                success: (data) ->
                    callback(data)
            )
        else
            console.log("There is no defined state!");



    #
    # Update the node value depending the perequation
    #
    updateNodeValue: () =>
        _.each(@nodes, (element, index, list) =>
            switch @currentState.perequation
                when "dmto" then element.value = element.dmto.value
                when "fpic" then element.value = element.fpic.value
                else element.value = element.total.value
        )

        # When node values are updated, update scaling function
        this.updateCircleSizeScale()
        this.updateCircleRichessePositionScale()



    #
    # Update the circle size scale function depending updated values
    #
    updateCircleSizeScale: () =>
        # Find the node with the min value
        min = _.min(@nodes, (node)->
                return Math.abs(node.value)
            )
        # Find the node with the max value
        max = _.max(@nodes, (node)->
                return Math.abs(node.value)
            )

        if @nodes.length < 30
            circleMinSize =  @graphSettings.circleRange.min
            circleMaxSize =  @graphSettings.circleRange.max
        else
            circleMinSize = @graphSettings.circleRange.min / 2
            circleMaxSize =  @graphSettings.circleRange.max / 2

        # Update the scale fonction with the new range
        @circleSizeScale = d3.scale.linear().domain([Math.abs(min.value), Math.abs(max.value)]).range([circleMinSize, circleMaxSize])

        # For every node, update the radius value
        _.each(@nodes, (element, index, list) =>
            element.radius = @circleSizeScale(Math.abs(element.value))
        )



    #
    # Update the circle richesse position scale function depending updated values
    #
    updateCircleRichessePositionScale: () =>
        # Find the node with the min value
        minRevenu = _.min(@nodes, (node)->
                return node.revenu.value
            )
        # Find the node with the max value
        maxRevenu = _.max(@nodes, (node)->
                return node.revenu.value
            )

        @axeExtremeValues.revenu.min = minRevenu.revenu.value
        @axeExtremeValues.revenu.max = maxRevenu.revenu.value

        # Update the scale fonction with the new range
        @circleRichesseRevenuPositionScale = d3.scale.linear().domain([minRevenu.revenu.value, maxRevenu.revenu.value]).range([@graphSettings.centers.receive.x - 50, @graphSettings.centers.give.x + 50])

        if @currentState.type == "regions"
            # Find the node with the min value
            minPotentiel = _.min(@nodes, (node)->
                    return node.potentielFiscal.value
                )
            # Find the node with the max value
            maxPotentiel = _.max(@nodes, (node)->
                    return node.potentielFiscal.value
                )

            @axeExtremeValues.potentiel.min = minPotentiel.potentielFiscal.value
            @axeExtremeValues.potentiel.max = maxPotentiel.potentielFiscal.value

            # Update the scale fonction with the new range
            @circleRichessePotentielPositionScale = d3.scale.linear().domain([minPotentiel.potentielFiscal.value, maxPotentiel.potentielFiscal.value]).range([@graphSettings.centers.receive.x - 50, @graphSettings.centers.give.x + 50])



    #
    # After updating nodes values, make a transition to update circle size
    #
    updateCircleShape: () =>
        # Update every node with update to date data
        @vis.selectAll("circle")
                .data(@nodes, (d) => @currentState.type + "_#{d.id}")
                # launch a transition to update circle radius and color
                .transition()
                .duration(@graphSettings.animationSpeed)
                .attr("r", (d) => return d.radius)
                .attr("fill", (d) => this.getNodeColor(d))
                .attr("stroke", (d) => d3.rgb(this.getNodeColor(d)).darker())



    #
    # Update node center for every node
    #
    updateCircleCenter: () =>
        # For every node, set the new center
        @centers.length = 0
        _.each(@nodes, (element, index, list) =>
            element.center = this.getNodeCenter(element)
        )


    #
    # Update node url
    #
    updateNodeUrl: () =>
        @vis.selectAll("a")
                    .attr("xlink:href", (d) => this.generateNewLevelUrl(d.levelId))
    #
    # Calculate the charge of a node depending its size
    #
    charge: (d) =>
        -Math.pow(d.radius, 2.0) / 8


    #
    # Define the new center of a node depending its value
    #
    moveTowardsCenter: (alpha) =>
        (d) =>
            center = this.getNodeCenter(d)
            d.x = d.x + (center.x - d.x) * (@graphSettings.damper + 0.02) * alpha * 1.1
            d.y = d.y + (center.y - d.y) * (@graphSettings.damper + 0.02) * alpha * 1.1



    #
    # Find the appropriate center depending the node value and the view
    #
    getNodeCenter: (node) =>
        # Get the node center depending the view
        if @currentState.view == "donnees"
            # If the view is donnees, the center depend on the value
            if node.value > 999
                return @graphSettings.centers.receive
            else if node.value < -999
                return @graphSettings.centers.give
            else
                return @graphSettings.centers.neutral
        else
            # if not, it is the view richesse, then it depends on the revenu_hab
            if @currentState.type == "regions" and @currentState.richesse == "potentiel"
                return center =
                    x : @circleRichessePotentielPositionScale(node.potentielFiscal.value)
                    y : @graphSettings.height / 2
            else
                return center =
                    x : @circleRichesseRevenuPositionScale(node.revenu.value)
                    y : @graphSettings.height / 2


    #
    # Find the appropriate color depending the node value
    #
    getNodeColor: (node) =>
        if node.value > 999
            return @graphSettings.colors.receive
        else if node.value < -999
            return @graphSettings.colors.give
        else
            return @graphSettings.colors.neutral


    #
    # Generate a new History state
    #
    generateNewHistoryState: (stateAttributes, force=false) =>
        # Store old state
        @rollbackState = _.clone(@currentState)

        if force
            # force to override every attributes (used for rollback)
            @currentState = stateAttributes
        else
            # update the currentStage with new state attributes
            _.extend(@currentState, stateAttributes)

        # Generate the new title depending the current state
        title = this.generateTitle(@currentState)

        # Generate the new url depending the current state
        url = this.generateUrl()

        page = url.replace(@appSettings.applicationRootUrl, '')

        # Push a new state in the history
        ga('send', 'pageview', {'page': page,'title': title});

        History.pushState(@currentState, title, url)



    #
    # Generate title depending state attributes
    #
    generateTitle: (state) =>
        # Generate a new title
        title = "A qui profitent les péréquations :"

        switch @currentState.view
            when "donnees" then  title += " Données"
            when "richesse" then title += " Richesse"
            when "comparer" then title += " Comparer"

        switch @currentState.perequation
            when "toutes" then title += " - Toutes les péréquations"
            when "dmto" then title += " - DMTO"
            when "fpic" then title += " - FPIC"

        switch @currentState.type
            when "france" then title += " - France"
            when "regions" then title += " - Région:"
            when "departements" then title += " - Département:"

        if (@currentState.type == "regions" || @currentState.type == "departements") && @currentState.id
            if @currentState.name
                title += " " + @currentState.name
            else
                title += " " + @currentState.id

        return title



    #
    # Generate a new url overriding the current state
    #
    generateUrl: (newStateAttributes) =>
        # Make a copy of state attributes
        stateAttributes = _.clone(@currentState)

        # Override state attributes with the new ones
        _.extend(stateAttributes, newStateAttributes)

        url = @appSettings.applicationRootUrl + "/" + stateAttributes.view + "/" + stateAttributes.perequation + "/" + stateAttributes.type

        if stateAttributes.id
            url += "/" + stateAttributes.id

        if stateAttributes.view == "richesse" and stateAttributes.richesse
            url += "/" + stateAttributes.richesse

        return url


    #
    # Generate a new url for the up or down level
    #
    generateNewLevelUrl: (id = "", down = true) =>
        # Initialize new newStateAttributes to generate a new url
        newStateAttributes =
            type: null
            id: null

        # If the next level is down
        if down
            # Let's find the new type depending the previous one
            if @currentState.type == "france"
                newStateAttributes.type = "regions"
            if @currentState.type == "regions"
                newStateAttributes.type = "departements"
                # Only FPIC are available for departements view
                newStateAttributes.perequation = "fpic"
            # Let's update the id attribute
            newStateAttributes.richesse = "revenu"
            newStateAttributes.id = id

        else
            if @currentState.type == "regions"
                newStateAttributes.type = "france"
                if @currentState.view == "richesse"
                    newStateAttributes.richesse = "revenu"
            if @currentState.type == "departements"
                newStateAttributes.type = "regions"
            newStateAttributes.id = id


        # Generate the new url depending the previous attribute
        return this.generateUrl(newStateAttributes)


    #
    # Update page component depending the current state
    #
    updatePageComponents: () =>
        if not @currentState
            this.getCurrentState()

        $(".perequation .btn.active").removeClass("active")
        $(".perequation .btn.#{@currentState.perequation}").addClass("active")

        # Hide notice "potentiel fiscal" if not regions level
        if @currentState.type == "regions"
            $(".notice.richesse .departement").show()
        else
            $(".notice.richesse .departement").hide()

        # Disable fpic on view type departements
        if @currentState.type == "departements"
            $(".perequation .btn:not(.fpic)").addClass("disabled")
        else
            $(".perequation .btn.disabled").removeClass("disabled")




        if @currentState.view == "richesse"
            # Draw arrow on view richesse
            d3.selectAll("g.richesse-line, g.min-value, g.max-value")
                .transition()
                    .duration(@graphSettings.animationSpeed / 2)
                    .attr("opacity", 1)

            # Hide group label
            d3.selectAll("g.group-label")
                .transition()
                    .duration(@graphSettings.animationSpeed / 2)
                    .attr("opacity", 0)

            # Display the right notice
            $(".notices").removeClass("donnees").addClass("richesse")

        else
            # Hide arrow on view richesse
            d3.selectAll("g.richesse-line, g.min-value, g.max-value")
                .transition()
                    .duration(@graphSettings.animationSpeed / 2)
                    .attr("opacity", 0)

            # Display group label
            d3.selectAll("g.group-label")
                .transition()
                    .duration(@graphSettings.animationSpeed / 2)
                    .attr("opacity", 1)

            # Display the right notice
            $(".notices").removeClass("richesse").addClass("donnees")

        # Hide richesse selector if not on richesse view and type departement or intercos
        if @currentState.view == "richesse"
            # Activate the right view selector
            $(".view_selector .donnees").removeClass("active")
            $(".view_selector .richesse").addClass("active")

            $(".richesse_selector").css("visibility", "visible")

            # Disable richesse button if on type france
            if @currentState.type == "regions"
                $(".richesse_selector .btn.disabled").removeClass("disabled")
            else
                $(".richesse_selector .btn:not(.revenu)").addClass("disabled")

            # Activate the right richesse selector
            if @currentState.richesse == "potentiel"
                $(".richesse_selector .potentiel").addClass("active")
                $(".richesse_selector .revenu").removeClass("active")
                d3.select("g.min-value text").text("#{this.numberFormat @axeExtremeValues.potentiel.min} €")
                d3.select("g.max-value text").text("#{this.numberFormat @axeExtremeValues.potentiel.max} €")
            else
                $(".richesse_selector .potentiel").removeClass("active")
                $(".richesse_selector .revenu").addClass("active")
                d3.select("g.min-value text").text("#{this.numberFormat @axeExtremeValues.revenu.min} €")
                d3.select("g.max-value text").text("#{this.numberFormat @axeExtremeValues.revenu.max} €")
        else
            $(".richesse_selector").css("visibility", "hidden")
            # Active the right view selector
            $(".view_selector .donnees").addClass("active")
            $(".view_selector .richesse").removeClass("active")

        this.updateSubTitle()



    #
    # Extract state from an url
    #
    extractStateFromUrl: (url) =>
        uri_re = new RegExp("^" + @appSettings.applicationRootUrl + "/(donnees|richesse|comparer)/(toutes|dmto|fpic)/(france|regions|departements)/?([0-9A-B]{1,3})?/?(potentiel|revenu)?$")
        uri_match = uri_re.exec(url)

        # If the url is correct and can be parse, let's initialize a new state
        if uri_match
            state =
                view : uri_match[1]
                perequation : uri_match[2]
                type : uri_match[3]
                id : uri_match[4]
                richesse: uri_match[5]

            if state.type != "regions" and state.view == "richesse"
                state.richesse = "revenu"

            # At departements level, perequation always = fpic
            if state.type == "departements"
                state.perequation = "fpic"
            return state
        else
            return null



    #
    # Emit a new pushState on navigation click
    #

    pushNewStateFromUrl: (url) =>
        # Get the new state from the url
        state = this.extractStateFromUrl(url)
        # Add the type of change to reload data
        state.change = "level"
        # Generate the new history state
        this.generateNewHistoryState(state)



    #
    # Update subtitle on level change
    #
    updateSubTitle: () =>
        switch @currentState.type
            when "france" then title = "Les données par régions"
            when "regions" then title = "Les départements de la région " + this.getLevelCollectiviteName(@currentState.type, @currentState.id)
            when "departements" then title = "Les intercommunalités du département " + this.getLevelCollectiviteName(@currentState.type, @currentState.id)

        $("nav.perequation_level h2").text(title)



    #
    # Update previous level url
    #
    updatePreviousLevelUrl: () =>
        # Update the previous level url
        if @currentState.type == "france"
            $("nav.perequation_level .change_level").css("visibility", "hidden")
            $("nav.perequation_level .change_level").attr("href", this.generateUrl())
        else if @currentState.type == "regions"
            $("nav.perequation_level .change_level .level_name").text("Les données par régions")
            $("nav.perequation_level .change_level").css("visibility", "visible")
            $("nav.perequation_level .change_level").attr("href", this.generateNewLevelUrl(null, false))
        else if @currentState.type == "departements"
            $("nav.perequation_level .change_level").css("visibility", "visible")
            regionId = this.getPreviousDepartementInfos(@currentState.departementId)
            $("nav.perequation_level .change_level .level_name").text("Les départements de la région " + this.getLevelCollectiviteName("regions", regionId))
            $("nav.perequation_level .change_level").attr("href", this.generateNewLevelUrl(regionId, false))

    #
    # Display tooltip with information inside
    #
    displayTooltip: (node, circle, link = false)=>
        # If the mouseover is on a link, we must find the circle next to the link
        if link
            groupId = d3.select(circle).attr('groupId')
            circle = d3.select("g##{groupId} circle")[0][0]

        # Update circle style to show which one is selected
        d3.select(circle)
            .attr("fill-opacity", 1)

        # Build the content of the tooltip

        content = "<div class=\"title\">#{node.nom}</div>
            <ul>
                <li class='header'>Population</li>"
        if isNaN(node.population)
            content += "<li>Données non disponibles</li>"
        else
            content += "<li>#{format( @appSettings.numberFormat, node.population)} habitants</li>"
        content += "<li class='header'>Revenu par habitant</li>
                <li>#{format( @appSettings.numberFormat, node.revenu.value)} &euro; / Rang : #{node.revenu.rang}</li>
                <li>Moyenne nationale : #{format( @appSettings.numberFormat, node.revenu.moyen)} &euro;</li>
                <li class='header'>Perequations</li>
            "

        if isNaN(node.total.habRang)
            content += "<li class='section'><b>Total par habitant : #{this.numberFormat node.total.hab} &euro; / Rang : non applicable</b></li>"
        else
            content += "<li class='section'><b>Total par habitant : #{this.numberFormat node.total.hab} &euro; / Rang : #{node.total.habRang}</b></li>"
        if isNaN(node.total.rang)
            content += "<li>Total : #{this.numberFormat node.total.value} &euro; / Rang : non applicable</li>"
        else
            content += "<li>Total : #{this.numberFormat node.total.value} &euro; / Rang : #{node.total.rang}</li>"

        if isNaN(node.fpic.habRang)
            content += "<li class='section'><b>FPIC par habitant : #{this.numberFormat node.fpic.hab} &euro; / Rang : non applicable</b></li>"
        else
            content += "<li class='section'><b>FPIC par habitant : #{this.numberFormat node.fpic.hab} &euro; / Rang : #{node.fpic.habRang}</b></li>"
        if isNaN(node.fpic.rang)
            content += "<li>FPIC : #{this.numberFormat node.fpic.value} &euro; / Rang : non applicable</li>"
        else
            content += "<li>FPIC : #{this.numberFormat node.fpic.value} &euro; / Rang : #{node.fpic.rang}</li>"


        if @currentState.type != "departements"
            if isNaN(node.dmto.habRang)
                content += "<li class='section'><b>DMTO par habitant : #{this.numberFormat node.dmto.hab} &euro; / Rang : non applicable</b></li>"
            else
                content += "<li class='section'><b>DMTO par habitant : #{this.numberFormat node.dmto.hab} &euro; / Rang : #{node.dmto.habRang}</b></li>"
            if isNaN(node.dmto.rang)
                content += "<li>DMTO : #{this.numberFormat node.dmto.value} &euro; / Rang : non applicable</li>"
            else
                content += "<li>DMTO : #{this.numberFormat node.dmto.value} &euro; / Rang : #{node.dmto.rang}</li>"

        if @currentState.type != "france" and node.potentielFiscal and node.potentielFiscal.value
            content += "<li class='header'>Potentiel fiscal par habitant</li>
                        <li>#{this.numberFormat node.potentielFiscal.value} &euro; / Rang : #{node.potentielFiscal.rang}</li>
                        <li>Moyenne nationale : #{this.numberFormat node.potentielFiscal.moyen} &euro;</li>"

        content += "</ul>"
        # Add the content to the tooltip
        tooltip = $(".circle-tooltip")
        tooltip.css("height", "auto")
        tooltip.html(content)
        height = tooltip.height()

        tooltip.removeAttr("style")


        params =
            top : Math.round(node.y - (height / 2) - 10) + "px"
        if node.x < (@graphSettings.width / 2)
            params.left = Math.round(node.x + 50) + "px"
            tooltip.removeClass('right')
            tooltip.addClass('left')
        else
            params.right = Math.round(@graphSettings.width - node.x + 50) + "px"
            tooltip.removeClass('left')
            tooltip.addClass('right')


        tooltip.css(params)
        tooltip.addClass("show")

    #
    # Hide the tooltip
    #
    hideTooltip: (circle = false) =>
        if circle
            d3.select(circle)
                .attr("fill-opacity", @graphSettings.circleOpacity)
        $(".circle-tooltip").removeClass("show")

    leadingZero: (id) ->
        if String(id).length == 1
            "0#{id}"
        else
            String(id)

    numberFormat: (number) =>
        if parseInt(number) > 0
            "+ #{format @appSettings.numberFormat, number}"
        else
            format @appSettings.numberFormat, number

    getLevelCollectiviteName: (level, id) ->
        regions =
            '11': 'Ile-de-France'
            '21': 'Champagne-Ardenne'
            '22': 'Picardie'
            '23': 'Haute-Normandie'
            '24': 'Centre'
            '25': 'Basse-Normandie'
            '26': 'Bourgogne'
            '31': 'Nord-Pas-de-Calais'
            '41': 'Lorraine'
            '42': 'Alsace'
            '43': 'Franche-Comté'
            '52': 'Pays-de-La-Loire'
            '53': 'Bretagne'
            '54': 'Poitou-Charentes'
            '72': 'Aquitaine'
            '73': 'Midi-Pyrénées'
            '74': 'Limousin'
            '82': 'Rhone-Alpes'
            '83': 'Auvergne'
            '91': 'Languedoc-Roussillon'
            '93': 'Provence-Alpes-Côte-d\'Azur'
            '94': 'Corse'

        departements =
            '62': 'Pas-de-Calais'
            '57': 'Moselle'
            '67': 'Bas-Rhin'
            '49': 'Maine-et-Loire'
            '29': 'Finistère'
            '22': 'Côtes-dArmor'
            '2': 'Aisne'
            '71': 'Saône-et-Loire'
            '42': 'Loire'
            '23': 'Creuse'
            '54': 'Meurthe-et-Moselle'
            '72': 'Sarthe'
            '63': 'Puy-de-Dôme'
            '50': 'Manche'
            '80': 'Somme'
            '36': 'Indre'
            '27': 'Eure'
            '52': 'Haute-Marne'
            '88': 'Vosges'
            '48': 'Lozère'
            '43': 'Haute-Loire'
            '86': 'Vienne'
            '79': 'Deux-Sèvres'
            '53': 'Mayenne'
            '70': 'Haute-Saône'
            '81': 'Tarn'
            '55': 'Meuse'
            '15': 'Cantal'
            '3': 'Allier'
            '24': 'Dordogne'
            '8': 'Ardennes'
            '61': 'Orne'
            '12': 'Aveyron'
            '47': 'Lot-et-Garonne'
            '25': 'Doubs'
            '16': 'Charente'
            '7': 'Ardèche'
            '58': 'Nièvre'
            '87': 'Haute-Vienne'
            '19': 'Corrèze'
            '89': 'Yonne'
            '18': 'Cher'
            '65': 'Hautes-Pyrénées'
            '9': 'Ariège'
            '41': 'Loir-et-Cher'
            '32': 'Gers'
            '46': 'Lot'
            '82': 'Tarn-et-Garonne'
            '39': 'Jura'
            '10': 'Aube'
            '2B': 'Haute-Corse'
            '90': 'Territoire de Belfort'
            '5': 'Hautes-Alpes'
            '4': 'Alpes-de-Haute-Provence'
            '11': 'Aude'
            '28': 'Eure-et-Loir'
            '51': 'Marne'
            '45': 'Loiret'
            '37': 'Indre-et-Loire'
            '85': 'Vendée'
            '40': 'Landes'
            '21': 'Côte-dOr'
            '66': 'Pyrénées-Orientales'
            '68': 'Haut-Rhin'
            '56': 'Morbihan'
            '60': 'Oise'
            '30': 'Gard'
            '14': 'Calvados'
            '1': 'Ain'
            '35': 'Ille-et-Vilaine'
            '2A': 'Corse-du-Sud'
            '64': 'Pyrénées-Atlantiques'
            '26': 'Drôme'
            '17': 'Charente-Maritime'
            '76': 'Seine-Maritime'
            '84': 'Vaucluse'
            '34': 'Hérault'
            '73': 'Savoie'
            '31': 'Haute-Garonne'
            '95': 'Val-dOise'
            '77': 'Seine-et-Marne'
            '38': 'Isère'
            '44': 'Loire-Atlantique'
            '33': 'Gironde'
            '59': 'Nord'
            '93': 'Seine-Saint-Denis'
            '91': 'Essonne'
            '74': 'Haute-Savoie'
            '94': 'Val-de-Marne'
            '13': 'Bouches-du-Rhône'
            '83': 'Var'
            '69': 'Rhône'
            '78': 'Yvelines'
            '6': 'Alpes-Maritimes'
            '92': 'Hauts-de-Seine'
            '75': 'Paris'

        if (level == "regions")
            return regions[String(id)]
        else if (level == "departements")
            return departements[String(id)]

    getPreviousDepartementInfos: (departementId) =>
        departements =
            '1': '82'
            '10': '21'
            '11': '91'
            '12': '73'
            '13': '93'
            '14': '25'
            '15': '83'
            '16': '54'
            '17': '54'
            '18': '24'
            '19': '74'
            '2': '22'
            '2A': '94'
            '2B': '94'
            '21': '26'
            '22': '53'
            '23': '74'
            '24': '72'
            '25': '43'
            '26': '82'
            '27': '23'
            '28': '24'
            '29': '53'
            '3': '83'
            '30': '91'
            '31': '73'
            '32': '73'
            '33': '72'
            '34': '91'
            '35': '53'
            '36': '24'
            '37': '24'
            '38': '82'
            '39': '43'
            '4': '93'
            '40': '72'
            '41': '24'
            '42': '82'
            '43': '83'
            '44': '52'
            '45': '24'
            '46': '73'
            '47': '72'
            '48': '91'
            '49': '52'
            '5': '93'
            '50': '25'
            '51': '21'
            '52': '21'
            '53': '52'
            '54': '41'
            '55': '41'
            '56': '53'
            '57': '41'
            '58': '26'
            '59': '31'
            '6': '93'
            '60': '22'
            '61': '25'
            '62': '31'
            '63': '83'
            '64': '72'
            '65': '73'
            '66': '91'
            '67': '42'
            '68': '42'
            '69': '82'
            '7': '82'
            '70': '43'
            '71': '26'
            '72': '52'
            '73': '82'
            '74': '82'
            '75': '11'
            '76': '23'
            '77': '11'
            '78': '11'
            '79': '54'
            '8': '21'
            '80': '22'
            '81': '73'
            '82': '73'
            '83': '93'
            '84': '93'
            '85': '52'
            '86': '54'
            '87': '74'
            '88': '41'
            '89': '26'
            '9': '73'
            '90': '43'
            '91': '11'
            '92': '11'
            '93': '11'
            '94': '11'
            '95': '11'

        return departements[String(departementId)]

$ ->
    if $("#app").length > 0
        new Perequations