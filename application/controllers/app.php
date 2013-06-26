<?php

class App_Controller extends Base_Controller {

  public function __construct(){

    Asset::container('head')->add('modernizr', 'js/vendor/modernizr-2.6.2-respond-1.1.0.min.js');

    Asset::container('footer')->add('jquery', 'js/vendor/jquery-1.9.1.min.js');
    Asset::container('footer')->add('history-js', 'js/vendor/jquery.history.js', 'jquery');
    Asset::container('footer')->add('bootstrap-js', 'js/vendor/bootstrap.min.js');
    Asset::container('footer')->add('underscore-js', 'js/vendor/underscore.min.js');
    Asset::container('footer')->add('d3-js', 'js/vendor/d3.v3.min.js');
    Asset::container('footer')->add('format', 'js/vendor/format.20110630-1100.min.js');

    if (Laravel\Request::is_env('local')) {
      Asset::container('footer')->add('main-js', 'js/main.js', array('jquery', 'bootstrap-js', 'underscore-js', 'd3-js', 'format'));
    }
    else {
      Asset::container('footer')->add('main-js', 'js/main.min.js', array('jquery', 'bootstrap-js', 'underscore-js', 'd3-js', 'format'));
    }

    Asset::container('head')->add('bootstrap-css', 'css/bootstrap.min.css');
    Asset::container('head')->add('bootstrap-css-responsive', 'css/bootstrap-responsive.min.css', 'bootstrap-css');
    Asset::container('head')->add('main.css', 'css/screen.css', array('bootstrap-css', 'bootstrap-css-responsive', 'socialcount-css'));

    parent::__construct();
  }

  public function action_index($vue, $perequation, $niveau, $id_collectivite=0, $richesse=null){
    // Check url is valid
    if ($this->is_valid_url_format($vue, $perequation, $niveau, $id_collectivite)){
      // Check user is authorized
      if ($this->isAuthorized($niveau)){
        // User is authorized, let's show the app
        return View::make('app.index')
                      ->with('title', $this->generateAppTitle($vue, $perequation, $niveau, $id_collectivite))
                      ->with('subtitle', $this->generateAppSubtitle($vue, $perequation, $niveau, $id_collectivite))
                      ->with('vue', $vue)
                      ->with('perequation', $perequation)
                      ->with('richesse', $richesse)
                      ->with('niveau', $niveau)
                      ->with('root_url', URL::base());

      }
      else {
        // The user is not authorized, let's redirect him to the gazette authentication page
        if (Laravel\Request::is_env('local')) {
          return Redirect::to("http://test.services.lagazettedescommunes.com/users.php/magazette/identification?reserve=1&club=7&Goingto=" . URL::current());
        }
        else {
          return Redirect::to("http://services.lagazettedescommunes.com/users.php/magazette/identification?reserve=1&club=7&Goingto=" . URL::current());
        }
      }
    }
    else {
      return Redirect::to(URL::base());
    }
  }

  private function is_valid_url_format($vue, $perequation, $niveau, $id_collectivite){
    $valid =  in_array($vue, array("donnees", "richesse"))
              && in_array($perequation, array("toutes", "dmto", "fpic"))
              && in_array($niveau, array("france", "regions", "departements"));

    if ($niveau == "france") {
      $valid = true;
    }

    if ($niveau == "regions" || $niveau == "departements") {
      $valid = $valid && (is_numeric($id_collectivite) || $id_collectivite == "20A" || $id_collectivite == "20B");
    }

    return $valid;
  }

  private function isAuthorized($type_collectivite, $comparer = false){
    if ($type_collectivite == "france" or ($comparer == true and $type_collectivite == "regions")){
      return true;
    }

    $authorized = false;

    if (array_key_exists('espace_autorises', $_COOKIE)){
      $espace_autorises = $_COOKIE['espace_autorises'];
      if (is_string($espace_autorises)){
        $espaces = explode('|', $espace_autorises);
        if (in_array('GAZ08', $espaces) && in_array('GAZ09', $espaces)){
          $authorized = true;
        }
      }
    }

    return $authorized;
  }

  private function generateAppTitle($vue, $perequation, $niveau, $id_collectivite){
    $title = "A qui profite la péréquation :";

    switch ($vue){
      case "donnees":
        $title .= " Données";
        break;
      case "richesse":
        $title .= " Richesse";
        break;
    }

    switch ($perequation){
      case "toutes":
        $title .= " - Toutes les péréquations";
        break;
      case "dmto":
        $title .= " - DMTO";
        break;
      case "fpic":
        $title .= "  - FPIC";
        break;
    }

    switch ($niveau){
      case "france":
        $title .= " - France";
        break;
      case "regions":
        $title .= " - Région:";
        break;
      case "departements":
        $title .= " - Département:";
        break;
    }

    if (($niveau == "regions" || $niveau == "departements") && $id_collectivite){
      $title .= " " + $id_collectivite;
    }

    return $title;
  }

  private function generateAppSubtitle($vue, $perequation, $niveau, $id_collectivite){
    $title = "Les donn&eacute;es par ";

    switch ($niveau){
      case "france":
        $title .= "r&eacute;gion";
        break;
      case "regions":
        $title .= "département";
        break;
      case "departements":
        $title .= "intercommunalit&eacute;";
        break;
    }

    return $title;
  }
}