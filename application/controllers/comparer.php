<?php

class Comparer_Controller extends Base_Controller {

  public function __construct(){
    Asset::container('footer')->add('jquery', 'js/vendor/jquery-1.9.1.min.js');
    Asset::container('footer')->add('history-js', 'js/vendor/jquery.history.js', 'jquery');
    Asset::container('footer')->add('bootstrap-js', 'js/vendor/bootstrap.min.js');
    Asset::container('footer')->add('underscore-js', 'js/vendor/underscore.min.js');
    Asset::container('footer')->add('format', 'js/vendor/format.20110630-1100.min.js');
    if (Laravel\Request::is_env('local')) {
      Asset::container('footer')->add('comparer-js', 'js/comparer.js', array('jquery', 'bootstrap-js', 'underscore-js', 'format'));
    }
    else {
      Asset::container('footer')->add('comparer-js', 'js/comparer.min.js', array('jquery', 'bootstrap-js', 'underscore-js', 'format'));
    }

    Asset::container('head')->add('bootstrap-css', 'css/bootstrap.min.css');
    Asset::container('head')->add('bootstrap-css-responsive', 'css/bootstrap-responsive.min.css', 'bootstrap-css');
    Asset::container('head')->add('main.css', 'css/screen.css', array('bootstrap-css', 'bootstrap-css-responsive', 'socialcount-css'));

    parent::__construct();
  }

  public function action_index($type_collectivite, $id_collectivite_1 = null, $id_collectivite_2 = null, $id_collectivite_3 = null){
    // First we check type_collectivite is correct
    if (in_array($type_collectivite, array("regions", "departements", "intercos"))){
      // Then we check the user is autorized
      if ($this->isAuthorized($type_collectivite, true)){

        $collectivites = $this->getCollectiviteInformations($type_collectivite, array($id_collectivite_1, $id_collectivite_2, $id_collectivite_3));

        // User is authorized, let's show the app
        return View::make('comparer.index')
                      ->with('title', $this->generateTitle($type_collectivite, $collectivites))
                      ->with('niveau', $type_collectivite)
                      ->with('root_url', URL::base());
      }
      else{
        // The user is not authorized, let's redirect him to the gazette authentication page
        if (Laravel\Request::is_env('local')) {
          return Redirect::to("http://test.services.lagazettedescommunes.com/users.php/magazette/identification?reserve=1&club=7&Goingto=" . URL::current());
        }
        else {
          return Redirect::to("http://services.lagazettedescommunes.com/users.php/magazette/identification?reserve=1&club=7&Goingto=" . URL::current());
        }
      }
    }
    else{
      return Redirect::to(URL::base());
    }
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


  private function generateTitle($type_collectivite, $collectivite_array){
    $title = "A qui profite la péréquation : Comparer ";

    switch ($type_collectivite){
      case "regions":
        $title .= "les régions ";
        break;
      case "departements":
        $title .= "les départements ";
        break;
      case "intercos":
        $title .= "les collectivités ";
        break;
    }

    $collectivites_noms = "";
    foreach ($collectivite_array as $key => $value) {
      if ($collectivites_noms != ""){
        $collectivites_noms .= ", ";
      }
      $collectivites_noms .= $value->nom;
    }

    $title .= $collectivites_noms;

    return $title;
  }

  private function getCollectiviteInformations($type_collectivite, $collectivite_array){
    $result = array();

    for ($i = 0, $l = count($collectivite_array); $i < $l; $i++) {
      $collectivite = $collectivite_array[$i];
      if ($collectivite){
        if ($type_collectivite == "regions"){
          $region = Region::find($collectivite);
          if ($region){
            array_push($result, $region);
          }
        }

        else if ($type_collectivite == "departements"){
          $departement = Departement::find($collectivite);
          if ($departement){
            array_push($result, $departement);
          }
        }

        else if ($type_collectivite == "intercos"){
          $interco = Interco::find($collectivite);
          if ($interco){
            array_push($result, $interco);
          }
        }
      }
    }

    return $result;
  }
}