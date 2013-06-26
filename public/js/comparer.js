// Generated by CoffeeScript 1.3.3
(function() {
  var Comparaison,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Comparaison = (function() {

    function Comparaison() {
      this.colorize = __bind(this.colorize, this);

      this.numberFormat = __bind(this.numberFormat, this);

      this.updatePageComponents = __bind(this.updatePageComponents, this);

      this.getInfoHtml = __bind(this.getInfoHtml, this);

      this.loadDataFromState = __bind(this.loadDataFromState, this);

      this.setIntercoDepartementSelection = __bind(this.setIntercoDepartementSelection, this);

      this.setOptionSelection = __bind(this.setOptionSelection, this);

      this.loadIntercoOptionList = __bind(this.loadIntercoOptionList, this);

      this.loadIntercoDepartementOptionList = __bind(this.loadIntercoDepartementOptionList, this);

      this.loadDepartementRegionOptionList = __bind(this.loadDepartementRegionOptionList, this);

      this.generateUrl = __bind(this.generateUrl, this);

      this.generateTitle = __bind(this.generateTitle, this);

      this.generateNewHistoryState = __bind(this.generateNewHistoryState, this);

      this.extractStateFromUrl = __bind(this.extractStateFromUrl, this);

      this.getCurrentState = __bind(this.getCurrentState, this);

      var that;
      this.appSettings = {
        applicationRootUrl: window.appUrl || window.location.protocol + '//' + window.location.hostname,
        numberFormat: "# ##0."
      };
      this.history = window.History;
      this.rollbackUrl = window.location.href;
      this.currentState = this.getCurrentState();
      this.initEvents();
      this.updatePageComponents();
      if (this.currentState.level !== "intercos") {
        this.loadDepartementRegionOptionList();
        this.loadDataFromState();
      } else {
        this.loadDataFromState();
        this.loadIntercoDepartementOptionList();
      }
      this.colors = {
        give: "#DD003F",
        neutral: "#F7C63C",
        receive: "#86BC31"
      };
      that = this;
    }

    Comparaison.prototype.initEvents = function() {
      var that,
        _this = this;
      that = this;
      $(document).ajaxError(function(event, jqXHR, ajaxSettings, thrownError) {
        $("body").removeClass('busy');
        if (jqXHR.status === 403) {
          return $('#unautorized').modal('show');
        }
      });
      $(document).ajaxStart(function() {
        return $("body").addClass('busy');
      });
      $(document).ajaxStop(function() {
        return $("body").removeClass('busy');
      });
      $(document).on("click", ".niveau a", function(event) {
        var level;
        event.preventDefault();
        level = $(this).data("level");
        $(".level").attr("class", "level " + level);
        return that.generateNewHistoryState({
          level: level,
          collectivite1: null,
          collectivite2: null,
          collectivite3: null,
          change: "level"
        });
      });
      $(document).on("change", ".choose", function(event) {
        var collectiviteId, currentState, newAttributes;
        currentState = that.getCurrentState();
        collectiviteId = $(this).data("collectivite");
        newAttributes = {};
        newAttributes["collectivite" + collectiviteId] = $(this).val();
        if (currentState.level === "intercos") {
          newAttributes["departement" + collectiviteId] = $(".collectivite" + collectiviteId + " .interco_departements option:selected").val();
        }
        newAttributes.change = "collectivite";
        return that.generateNewHistoryState(newAttributes);
      });
      $(document).on("change", ".interco_departements", function(event) {
        var collectiviteId, departementId;
        departementId = $(this).val();
        collectiviteId = $(this).data("collectivite");
        $(".collectivite.collectivite" + collectiviteId + " .infos").empty();
        $(".collectivite.collectivite" + collectiviteId + " .infos").removeClass("show");
        $(".collectivite.collectivite" + collectiviteId + " .choose").empty();
        return that.loadIntercoOptionList(departementId, collectiviteId);
      });
      $('#unautorized .rollback').on('click', function(event) {
        ga('send', 'event', 'subscription', 'no');
        return _this.generateNewHistoryState(null, true);
      });
      $('#unautorized .identify').on('click', function(event) {
        var currentUrl;
        currentUrl = window.location.href;
        if ($(_this).hasClass("register")) {
          ga('send', 'event', 'subscription', 'yes');
          ga('send', 'event', 'subscription-from', currentUrl);
        } else {
          ga('send', 'event', 'subscription', 'identify');
        }
        return window.location.href = encodeURI("" + _this.appSettings.applicationRootUrl + "/identifier?url=" + currentUrl);
      });
      return History.Adapter.bind(window, "statechange", function() {
        var currentState;
        currentState = that.getCurrentState();
        if (currentState.change === "level") {
          $(".collectivite .infos").empty();
          $(".collectivite .choose").empty();
          $(".collectivite .interco_departements option:selected").prop("selected", false);
          if (currentState.level !== "intercos") {
            that.loadDepartementRegionOptionList();
          } else {
            that.loadIntercoDepartementOptionList();
          }
        } else if (currentState.change === "collectivite") {
          that.loadDataFromState();
        }
        return that.updatePageComponents();
      });
    };

    Comparaison.prototype.getCurrentState = function() {
      var currentState;
      if (this.currentState) {
        return this.currentState;
      }
      currentState = this.extractStateFromUrl(window.location.href);
      if (currentState) {
        return this.currentState = currentState;
      } else {
        return false;
      }
    };

    Comparaison.prototype.extractStateFromUrl = function(url) {
      var state, uriIntercos, uriIntercosMatch, uriOtherMatch, uriOthers;
      uriIntercos = new RegExp("^" + this.appSettings.applicationRootUrl + "/comparer/intercos/?(?:([0-9A-B]{1,2})-([0-9]*))?/?(?:([0-9A-B]{1,2})-([0-9]*))?/?(?:([0-9A-B]{1,2})-([0-9]*))?$");
      uriOthers = new RegExp("^" + this.appSettings.applicationRootUrl + "/comparer/(regions|departements)/?([0-9A-B]*)?/?([0-9A-B]*)?/?([0-9A-B]*)?$");
      if (uriIntercosMatch = uriIntercos.exec(url)) {
        state = {
          level: "intercos",
          departement1: uriIntercosMatch[1],
          collectivite1: uriIntercosMatch[2],
          departement2: uriIntercosMatch[3],
          collectivite2: uriIntercosMatch[4],
          departement3: uriIntercosMatch[5],
          collectivite3: uriIntercosMatch[6]
        };
        return state;
      } else if (uriOtherMatch = uriOthers.exec(url)) {
        state = {
          level: uriOtherMatch[1],
          collectivite1: uriOtherMatch[2],
          collectivite2: uriOtherMatch[3],
          collectivite3: uriOtherMatch[4]
        };
        return state;
      } else {
        return null;
      }
    };

    Comparaison.prototype.generateNewHistoryState = function(stateAttributes, force) {
      var page, title, url;
      if (force == null) {
        force = false;
      }
      if (force) {
        window.location.href = this.rollbackUrl;
      } else {
        this.rollbackUrl = window.location.href;
        _.extend(this.currentState, stateAttributes);
      }
      title = this.generateTitle(this.currentState);
      url = this.generateUrl(this.currentState);
      page = url.replace(this.appSettings.applicationRootUrl, '');
      ga('send', 'pageview', {
        'page': page,
        'title': title
      });
      return History.pushState(this.currentState, title, url);
    };

    Comparaison.prototype.generateTitle = function(state) {
      var title;
      title = "A qui profitent les péréquations : Comparer les ";
      switch (this.currentState.level) {
        case "regions":
          title += " régions";
          break;
        case "departements":
          title += " départements";
          break;
        case "intercos":
          title += " intercommunalités";
      }
      if (this.currentState.collectivite1) {
        title += " " + this.currentState.collectivite1;
      }
      if (this.currentState.collectivite2) {
        title += " - " + this.currentState.collectivite2;
      }
      if (this.currentState.collectivite3) {
        title += " - " + this.currentState.collectivite3;
      }
      return title;
    };

    Comparaison.prototype.generateUrl = function(state) {
      var url;
      url = this.appSettings.applicationRootUrl + "/comparer/" + state.level;
      if (this.currentState.level !== "intercos") {
        if (this.currentState.collectivite1) {
          url += "/" + this.currentState.collectivite1;
        }
        if (this.currentState.collectivite2) {
          url += "/" + this.currentState.collectivite2;
        }
        if (this.currentState.collectivite3) {
          url += "/" + this.currentState.collectivite3;
        }
      } else {
        if (this.currentState.collectivite1) {
          url += "/" + this.currentState.departement1 + "-" + this.currentState.collectivite1;
        }
        if (this.currentState.collectivite2) {
          url += "/" + this.currentState.departement2 + "-" + this.currentState.collectivite2;
        }
        if (this.currentState.collectivite3) {
          url += "/" + this.currentState.departement3 + "-" + this.currentState.collectivite3;
        }
      }
      return url;
    };

    Comparaison.prototype.loadDepartementRegionOptionList = function() {
      var currentState, that,
        _this = this;
      currentState = this.getCurrentState();
      that = this;
      return $.ajax({
        url: this.appSettings.applicationRootUrl + "/api/liste/" + currentState.level,
        dataType: 'json',
        success: function(data) {
          var options;
          if (currentState.level === "regions") {
            options = "<option value=''>Choisir une région</option>";
          } else if (currentState.level === "departements") {
            options = "<option value=''>Choisir un département</option>";
          }
          _.each(data, function(collectivite) {
            return options += "<option value='" + collectivite.id + "'>" + (collectivite.nom.toUpperCase()) + "</option>";
          });
          $(".collectivite .choose").html(options);
          return that.setOptionSelection(currentState);
        }
      });
    };

    Comparaison.prototype.loadIntercoDepartementOptionList = function() {
      var currentState, that,
        _this = this;
      currentState = this.getCurrentState();
      that = this;
      return $.ajax({
        url: this.appSettings.applicationRootUrl + "/api/liste/departements",
        dataType: 'json',
        success: function(data) {
          var options;
          options = "<option value=''>Choisir un département</option>";
          _.each(data, function(collectivite) {
            return options += "<option value='" + collectivite.id + "'>" + (collectivite.nom.toUpperCase()) + "</option>";
          });
          $(".collectivite .interco_departements").html(options);
          return _.each(["1", "2", "3"], function(departementId) {
            if (currentState["departement" + departementId]) {
              that.setIntercoDepartementSelection(currentState["departement" + departementId], departementId);
              return that.loadIntercoOptionList(currentState["departement" + departementId], departementId);
            }
          });
        }
      });
    };

    Comparaison.prototype.loadIntercoOptionList = function(departementId, collectiviteId) {
      var currentState, that,
        _this = this;
      currentState = this.getCurrentState();
      that = this;
      return $.ajax({
        url: this.appSettings.applicationRootUrl + ("/api/liste/intercos?departement_id=" + departementId),
        dataType: 'json',
        success: function(data) {
          var options;
          options = "<option value=''>Choisir une intercommunalité</option>";
          _.each(data, function(collectivite) {
            return options += "<option value='" + collectivite.id + "'>" + (collectivite.nom.toUpperCase()) + "</option>";
          });
          $(".collectivite.collectivite" + collectiviteId + " .choose").html(options);
          return that.setOptionSelection(currentState);
        }
      });
    };

    Comparaison.prototype.setOptionSelection = function(state) {
      return _.each(["collectivite1", "collectivite2", "collectivite3"], function(collectivite_id) {
        if (state[collectivite_id]) {
          return _.each($("." + collectivite_id + " .choose option"), function(option) {
            if ($(option).val() === state[collectivite_id]) {
              return $(option).prop("selected", true);
            }
          });
        }
      });
    };

    Comparaison.prototype.setIntercoDepartementSelection = function(departementId, collectiviteId) {
      return _.each($(".collectivite" + collectiviteId + " .interco_departements option"), function(option) {
        if ($(option).val() === departementId) {
          return $(option).prop("selected", true);
        }
      });
    };

    Comparaison.prototype.loadDataFromState = function(callback) {
      var currentState, ids, that,
        _this = this;
      that = this;
      currentState = this.getCurrentState();
      ids = [];
      _.each(["collectivite1", "collectivite2", "collectivite3"], function(collectiviteId) {
        var collectivite_infos;
        collectivite_infos = $("." + collectiviteId + " .infos");
        if (currentState[collectiviteId]) {
          if (!(collectivite_infos.data("level") === currentState.level && collectivite_infos.data("id") === currentState[collectiviteId])) {
            return ids.push(currentState[collectiviteId]);
          }
        }
      });
      return $.ajax({
        url: this.appSettings.applicationRootUrl + "/api/comparer/" + currentState.level,
        data: {
          id: ids
        },
        dataType: 'json',
        success: function(data) {
          return _.each(["collectivite1", "collectivite2", "collectivite3"], function(collectiviteId) {
            var collectiviteSelection, currentCollectiviteInfo;
            collectiviteSelection = currentState[collectiviteId];
            if (collectiviteSelection && collectiviteSelection.length > 0) {
              if (collectiviteSelection in data) {
                currentCollectiviteInfo = $("." + collectiviteId + " .infos");
                currentCollectiviteInfo.html(that.getInfoHtml(data[collectiviteSelection], currentState.level));
                currentCollectiviteInfo.data("level", currentState.level);
                currentCollectiviteInfo.data("id", collectiviteSelection);
                currentCollectiviteInfo.addClass("show");
                if (callback) {
                  return callback();
                }
              }
            }
          });
        }
      });
    };

    Comparaison.prototype.getInfoHtml = function(data, level) {
      var content;
      content = "<div class=\"title\">" + data.nom + "</div>            <ul>                <li class='header'>Population</li>";
      if (data.population) {
        content += "<li>" + (format(this.appSettings.numberFormat, data.population)) + " habitants</li>";
      } else {
        content += "<li>Données non disponibles</li>";
      }
      content += "<li class='header'>Revenu par habitant</li>                <li>" + (format(this.appSettings.numberFormat, data.revenu_hab)) + " &euro; / Rang : " + data.revenu_hab_rang + "</li>                <li>Moyenne nationale : " + (format(this.appSettings.numberFormat, data.revenu_hab_moyen)) + " &euro;</li>                <li class='header'>Perequations</li>            ";
      if (data.total_hab_rang_2012) {
        content += "<li class='section'><b>Total par habitant : " + (this.numberFormat(data.total_hab_2012)) + " &euro; / Rang : " + data.total_hab_rang_2012 + "</b></li>";
      } else {
        content += "<li class='section'><b>Total par habitant : " + (this.numberFormat(data.total_hab_2012)) + " &euro; / Rang : non applicable</b></li>";
      }
      if (data.total_rang_2012) {
        content += ("<li>Total : " + (this.numberFormat(data.total_2012)) + " &euro; / ") + this.colorize("Rang : " + data.total_rang_2012, data.total_2012) + "</li>";
      } else {
        content += "<li>Total : " + (this.numberFormat(data.total_2012)) + " &euro; / Rang : non applicable</li>";
      }
      if (data.fpic_hab_rang_2012) {
        content += "<li class='section'><b>FPIC par habitant : " + (this.numberFormat(data.fpic_hab_2012)) + " &euro; / Rang : " + data.fpic_hab_rang_2012 + "</b></li>";
      } else {
        content += "<li class='section'><b>FPIC par habitant : " + (this.numberFormat(data.fpic_hab_2012)) + " &euro; / Rang : non applicable</b></li>";
      }
      if (data.fpic_rang_2012) {
        content += ("<li>FPIC : " + (this.numberFormat(data.fpic_2012)) + " &euro; / ") + this.colorize("Rang : " + data.fpic_rang_2012, data.fpic_2012) + "</li>";
      } else {
        content += "<li>FPIC : " + (this.numberFormat(data.fpic_2012)) + " &euro; / Rang : non applicable</li>";
      }
      if (level !== "intercos") {
        if (data.dmto_hab_rang_2012) {
          content += "<li class='section'><b>DMTO par habitant : " + (this.numberFormat(data.dmto_hab_2012)) + " &euro; / Rang : " + data.dmto_hab_rang_2012 + "</b></li>";
        } else {
          content += "<li class='section'><b>DMTO par habitant : " + (this.numberFormat(data.dmto_hab_2012)) + " &euro; / Rang : non applicable</b></li>";
        }
        if (data.dmto_rang_2012) {
          content += ("<li>DMTO : " + (this.numberFormat(data.dmto_2012)) + " &euro; / ") + this.colorize("Rang : " + data.dmto_rang_2012, data.dmto_2012) + "</li>";
        } else {
          content += "<li>DMTO : " + (this.numberFormat(data.dmto_2012)) + " &euro; / Rang : non applicable</li>";
        }
      }
      if (level !== "regions") {
        content += "<li class='header'>Potentiel fiscal par habitant</li>                        <li>" + (this.numberFormat(data.potentiel_fiscal_hab)) + " &euro; / Rang : " + (data.potentiel_fiscal_rang || data.potentiel_fiscal_hab_rang) + "</li>                        <li>Moyenne nationale : " + (this.numberFormat(data.potentiel_fiscal_moyen || data.potentiel_fiscal_hab_moyen)) + " &euro;</li>";
      }
      content += "</ul>";
      return content;
    };

    Comparaison.prototype.updatePageComponents = function() {
      var currentState;
      currentState = this.getCurrentState();
      if (!$(".niveau a.active").hasClass(currentState.level)) {
        $(".niveau a.active").removeClass("active");
        $(".niveau a." + currentState.level).addClass("active");
      }
      return _.each($(".collectivite .infos"), function(info) {
        if ($(info).is(':empty')) {
          return $(info).removeClass("show");
        }
      });
    };

    Comparaison.prototype.numberFormat = function(number) {
      if (parseInt(number) > 0) {
        return "+ " + (format(this.appSettings.numberFormat, number));
      } else {
        return format(this.appSettings.numberFormat, number);
      }
    };

    Comparaison.prototype.colorize = function(text, number) {
      var color;
      if (number > 999) {
        color = this.colors.receive;
      } else if (number < -999) {
        color = this.colors.give;
      } else {
        color = this.colors.neutral;
      }
      return "<b style='color: " + color + ";'>" + text + "</b>";
    };

    return Comparaison;

  })();

  $(function() {
    if ($("#comparer").length > 0) {
      return new Comparaison;
    }
  });

}).call(this);
