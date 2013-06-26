class Comparaison

    constructor: () ->
        # Define application settings
        @appSettings =
            applicationRootUrl : window.appUrl || window.location.protocol + '//' + window.location.hostname
            numberFormat: "# ##0."

        # Initialize history.js
        @history = window.History

        @rollbackUrl = window.location.href
        @currentState = this.getCurrentState()

        # Initialize events
        this.initEvents()
        this.updatePageComponents()

        if @currentState.level != "intercos"
            this.loadDepartementRegionOptionList()
            this.loadDataFromState()
        else
            this.loadDataFromState()
            this.loadIntercoDepartementOptionList()

        @colors =
            give: "#DD003F"
            neutral: "#F7C63C"
            receive: "#86BC31"

        that = this


    initEvents: () ->
        that = this

        # Catch unautorized ajax error, and display modal
        $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError) =>
            $("body").removeClass('busy')
            if jqXHR.status == 403
                $('#unautorized').modal('show')

        # Display and remove the ajax-loader gif on ajax request
        $(document).ajaxStart () ->
            $("body").addClass('busy')

        $(document).ajaxStop () ->
            $("body").removeClass('busy')

        # Push a new state when user click on level button
        $(document).on "click", ".niveau a", (event) ->
            event.preventDefault()
            level = $(this).data("level")
            $(".level").attr("class", "level #{level}")
            # We remove every collectivite attribute to empty info boxes
            that.generateNewHistoryState
                level: level
                collectivite1: null
                collectivite2: null
                collectivite3: null
                change: "level"

        # Push a new state when user change selection in one option list
        $(document).on "change", ".choose", (event) ->
            currentState = that.getCurrentState()
            collectiviteId = $(this).data("collectivite")
            newAttributes = {}
            newAttributes["collectivite#{collectiviteId}"] = $(this).val()

            if currentState.level == "intercos"
                newAttributes["departement#{collectiviteId}"] = $(".collectivite#{collectiviteId} .interco_departements option:selected").val()

            newAttributes.change = "collectivite"
            that.generateNewHistoryState newAttributes

        $(document).on "change", ".interco_departements", (event) ->
            departementId = $(this).val()
            collectiviteId = $(this).data("collectivite")

            $(".collectivite.collectivite#{collectiviteId} .infos").empty()
            $(".collectivite.collectivite#{collectiviteId} .infos").removeClass("show")
            $(".collectivite.collectivite#{collectiviteId} .choose").empty()

            that.loadIntercoOptionList departementId, collectiviteId

        # Handle unauthorized model button click
        $('#unautorized .rollback').on('click', (event) =>
            ga('send', 'event', 'subscription', 'no')
            # Rollback to the previous url
            this.generateNewHistoryState(null, true)
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

        # Handle when state change
        History.Adapter.bind window, "statechange", ->
            currentState = that.getCurrentState()

            # If the state changed because user changed level
            if currentState.change == "level"
                $(".collectivite .infos").empty()
                $(".collectivite .choose").empty()
                $(".collectivite .interco_departements option:selected").prop("selected", false)

                if currentState.level != "intercos"
                    that.loadDepartementRegionOptionList()
                else
                    that.loadIntercoDepartementOptionList()

            # If the state changed because user change an option
            else if currentState.change == "collectivite"
                that.loadDataFromState()

            # Always update page components
            that.updatePageComponents()




    #
    # Get the current state of the application using history api
    #
    getCurrentState: () =>
        return @currentState if @currentState

        currentState = this.extractStateFromUrl(window.location.href)
        if currentState
            return @currentState = currentState

        # If the url is not correct, we can't extract the state so we can't do anything else
        else
            return false



    #
    # Extract state from an url
    #
    extractStateFromUrl: (url) =>
        # Regex to get intercos state
        uriIntercos = new RegExp("^#{@appSettings.applicationRootUrl}/comparer/intercos/?(?:([0-9A-B]{1,2})-([0-9]*))?/?(?:([0-9A-B]{1,2})-([0-9]*))?/?(?:([0-9A-B]{1,2})-([0-9]*))?$")
        # Regex to get others state
        uriOthers = new RegExp("^#{@appSettings.applicationRootUrl}/comparer/(regions|departements)/?([0-9A-B]*)?/?([0-9A-B]*)?/?([0-9A-B]*)?$")

        # Extract state from url
        if uriIntercosMatch = uriIntercos.exec(url)
            state =
                level: "intercos"
                departement1: uriIntercosMatch[1]
                collectivite1: uriIntercosMatch[2]
                departement2: uriIntercosMatch[3]
                collectivite2: uriIntercosMatch[4]
                departement3: uriIntercosMatch[5]
                collectivite3: uriIntercosMatch[6]
            return state
        else if uriOtherMatch = uriOthers.exec(url)
            state =
                level : uriOtherMatch[1]
                collectivite1 : uriOtherMatch[2]
                collectivite2 : uriOtherMatch[3]
                collectivite3 : uriOtherMatch[4]
            return state
        else
            return null



    #
    # Generate a new History state
    #
    generateNewHistoryState: (stateAttributes, force=false) =>
        if force
            # Redirect user to previous url
            window.location.href = @rollbackUrl
        else
            # Store old url for rollback
            @rollbackUrl = window.location.href

            # update the currentStage with new state attributes
            _.extend(@currentState, stateAttributes)

        # Generate the new title depending the current state
        title = this.generateTitle(@currentState)

        # Generate the new url depending the current state
        url = this.generateUrl(@currentState)

        page = url.replace(@appSettings.applicationRootUrl, '')

        # Push a new state in the history
        ga('send', 'pageview', {'page': page,'title': title});

        History.pushState(@currentState, title, url)



    #
    # Generate title depending state attributes
    #
    generateTitle: (state) =>
        # Generate a new title
        title = "A qui profitent les péréquations : Comparer les "

        switch @currentState.level
            when "regions" then  title += " régions"
            when "departements" then title += " départements"
            when "intercos" then title += " intercommunalités"

        if @currentState.collectivite1
            title += " #{@currentState.collectivite1}"

        if @currentState.collectivite2
            title += " - #{@currentState.collectivite2}"

        if @currentState.collectivite3
            title += " - #{@currentState.collectivite3}"

        return title



    #
    # Generate a new url overriding the current state
    #
    generateUrl: (state) =>
        url = @appSettings.applicationRootUrl + "/comparer/" + state.level

        if @currentState.level != "intercos"
            if @currentState.collectivite1
                url += "/#{@currentState.collectivite1}"
            if @currentState.collectivite2
                url += "/#{@currentState.collectivite2}"
            if @currentState.collectivite3
                url += "/#{@currentState.collectivite3}"
        else
            if @currentState.collectivite1
                url += "/#{@currentState.departement1}-#{@currentState.collectivite1}"
            if @currentState.collectivite2
                url += "/#{@currentState.departement2}-#{@currentState.collectivite2}"
            if @currentState.collectivite3
                url += "/#{@currentState.departement3}-#{@currentState.collectivite3}"


        return url

    #
    # Load data and update list options depending currentState
    #
    loadDepartementRegionOptionList: () =>
        currentState = this.getCurrentState()
        that = this

        $.ajax
            url : @appSettings.applicationRootUrl + "/api/liste/" + currentState.level
            dataType: 'json'
            success: (data) =>
                if currentState.level == "regions"
                    options = "<option value=''>Choisir une région</option>"
                else if currentState.level == "departements"
                    options = "<option value=''>Choisir un département</option>"
                _.each data, (collectivite) ->
                    options += "<option value='#{collectivite.id}'>#{collectivite.nom.toUpperCase()}</option>"

                $(".collectivite .choose").html(options)
                that.setOptionSelection(currentState)


    #
    # Load list of departements for intercos
    #
    loadIntercoDepartementOptionList: () =>
        currentState = this.getCurrentState()
        that = this

        $.ajax
            url : @appSettings.applicationRootUrl + "/api/liste/departements"
            dataType: 'json'
            success: (data) =>
                # Load departements in every option list
                options = "<option value=''>Choisir un département</option>"
                _.each data, (collectivite) ->
                    options += "<option value='#{collectivite.id}'>#{collectivite.nom.toUpperCase()}</option>"

                $(".collectivite .interco_departements").html(options)

                # Now, if set selection on every list
                _.each ["1","2","3"], (departementId) ->
                    if currentState["departement#{departementId}"]
                        that.setIntercoDepartementSelection(currentState["departement#{departementId}"], departementId)
                        that.loadIntercoOptionList(currentState["departement#{departementId}"], departementId)


    #
    # Load list of intercos for a defined departement
    #
    loadIntercoOptionList: (departementId, collectiviteId) =>
        currentState = this.getCurrentState()
        that = this

        $.ajax
            url : @appSettings.applicationRootUrl + "/api/liste/intercos?departement_id=#{departementId}"
            dataType: 'json'
            success: (data) =>
                options = "<option value=''>Choisir une intercommunalité</option>"
                _.each data, (collectivite) ->
                    options += "<option value='#{collectivite.id}'>#{collectivite.nom.toUpperCase()}</option>"

                $(".collectivite.collectivite#{collectiviteId} .choose").html(options)
                that.setOptionSelection(currentState)



    #
    # Select the right option in option list depending the currentState
    #
    setOptionSelection: (state) =>
        _.each ["collectivite1", "collectivite2", "collectivite3"], (collectivite_id) ->
            if state[collectivite_id]
                _.each $(".#{collectivite_id} .choose option"), (option) ->
                    if $(option).val() == state[collectivite_id]
                        $(option).prop("selected", true)


    #
    # Select the right departement in intercos view
    #
    setIntercoDepartementSelection: (departementId, collectiviteId) =>
        _.each $(".collectivite#{collectiviteId} .interco_departements option"), (option) ->
            if $(option).val() == departementId
                $(option).prop("selected", true)


    #
    # Load needed data depending to currentState
    #
    loadDataFromState: (callback) =>
        that = this
        currentState = this.getCurrentState()

        ids = []

        _.each ["collectivite1", "collectivite2", "collectivite3"], (collectiviteId) ->
            collectivite_infos = $(".#{collectiviteId} .infos")
            if currentState[collectiviteId]
                unless collectivite_infos.data("level") == currentState.level and collectivite_infos.data("id") == currentState[collectiviteId]
                    ids.push(currentState[collectiviteId])

        $.ajax
            url : @appSettings.applicationRootUrl + "/api/comparer/" + currentState.level
            data:
                id : ids
            dataType: 'json'
            success: (data) =>
                _.each ["collectivite1", "collectivite2", "collectivite3"], (collectiviteId) ->
                    # Get current collectivite selected value
                    collectiviteSelection = currentState[collectiviteId]

                    # If the current collectivite as a selected value
                    if collectiviteSelection and collectiviteSelection.length > 0
                        # If this id exist in data
                        if collectiviteSelection of data
                            currentCollectiviteInfo = $(".#{collectiviteId} .infos")
                            currentCollectiviteInfo.html that.getInfoHtml(data[collectiviteSelection], currentState.level)
                            currentCollectiviteInfo.data "level", currentState.level
                            currentCollectiviteInfo.data "id", collectiviteSelection
                            currentCollectiviteInfo.addClass("show")

                            # If a callback is defined, execute it
                            if callback
                                callback()

    getInfoHtml: (data, level) =>
        content = "<div class=\"title\">#{data.nom}</div>
            <ul>
                <li class='header'>Population</li>"

        if data.population
            content += "<li>#{format( @appSettings.numberFormat, data.population)} habitants</li>"
        else
            content += "<li>Données non disponibles</li>"

        content += "<li class='header'>Revenu par habitant</li>
                <li>#{format( @appSettings.numberFormat, data.revenu_hab)} &euro; / Rang : #{data.revenu_hab_rang}</li>
                <li>Moyenne nationale : #{format( @appSettings.numberFormat, data.revenu_hab_moyen)} &euro;</li>
                <li class='header'>Perequations</li>
            "

        if data.total_hab_rang_2012
            content += "<li class='section'><b>Total par habitant : #{this.numberFormat data.total_hab_2012} &euro; / Rang : #{data.total_hab_rang_2012}</b></li>"
        else
            content += "<li class='section'><b>Total par habitant : #{this.numberFormat data.total_hab_2012} &euro; / Rang : non applicable</b></li>"

        if data.total_rang_2012
            content += "<li>Total : #{this.numberFormat data.total_2012} &euro; / " + this.colorize("Rang : #{data.total_rang_2012}", data.total_2012) + "</li>"
        else
            content += "<li>Total : #{this.numberFormat data.total_2012} &euro; / Rang : non applicable</li>"


        if data.fpic_hab_rang_2012
            content += "<li class='section'><b>FPIC par habitant : #{this.numberFormat data.fpic_hab_2012} &euro; / Rang : #{data.fpic_hab_rang_2012}</b></li>"
        else
            content += "<li class='section'><b>FPIC par habitant : #{this.numberFormat data.fpic_hab_2012} &euro; / Rang : non applicable</b></li>"
        if data.fpic_rang_2012
            content += "<li>FPIC : #{this.numberFormat data.fpic_2012} &euro; / " + this.colorize("Rang : #{data.fpic_rang_2012}", data.fpic_2012) + "</li>"
        else
            content += "<li>FPIC : #{this.numberFormat data.fpic_2012} &euro; / Rang : non applicable</li>"

        if level != "intercos"
            if data.dmto_hab_rang_2012
                content += "<li class='section'><b>DMTO par habitant : #{this.numberFormat data.dmto_hab_2012} &euro; / Rang : #{data.dmto_hab_rang_2012}</b></li>"
            else
                content += "<li class='section'><b>DMTO par habitant : #{this.numberFormat data.dmto_hab_2012} &euro; / Rang : non applicable</b></li>"
            if data.dmto_rang_2012
                content += "<li>DMTO : #{this.numberFormat data.dmto_2012} &euro; / " + this.colorize("Rang : #{data.dmto_rang_2012}", data.dmto_2012) + "</li>"
            else
                content += "<li>DMTO : #{this.numberFormat data.dmto_2012} &euro; / Rang : non applicable</li>"

        if level != "regions"
            content += "<li class='header'>Potentiel fiscal par habitant</li>
                        <li>#{this.numberFormat data.potentiel_fiscal_hab} &euro; / Rang : #{data.potentiel_fiscal_rang || data.potentiel_fiscal_hab_rang}</li>
                        <li>Moyenne nationale : #{this.numberFormat (data.potentiel_fiscal_moyen || data.potentiel_fiscal_hab_moyen)} &euro;</li>"

        content += "</ul>"

        return content

    updatePageComponents: () =>
        currentState = this.getCurrentState()

        # Set the right active level button depending to current state
        if not $(".niveau a.active").hasClass(currentState.level)
            $(".niveau a.active").removeClass("active")
            $(".niveau a.#{currentState.level}").addClass("active")

        _.each $(".collectivite .infos"), (info) ->
            if $(info).is(':empty')
                $(info).removeClass("show")

    numberFormat: (number) =>
        if parseInt(number) > 0
            "+ #{format @appSettings.numberFormat, number}"
        else
            format @appSettings.numberFormat, number

    #
    # Colorize text depending the number value using group color
    #
    colorize: (text, number) =>
        if number > 999
            color = @colors.receive
        else if number < -999
            color = @colors.give
        else
            color = @colors.neutral

        "<b style='color: #{color};'>#{text}</b>"




$ ->
    if $("#comparer").length > 0
        new Comparaison