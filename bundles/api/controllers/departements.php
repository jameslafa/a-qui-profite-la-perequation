<?php

class Api_Departements_Controller extends Base_Controller {

  public $restful = true;

  public function get_find_by_region($code_region) {
    if (is_numeric($code_region)){
      $departements = Cache::get('departements_find_by_region_' . $code_region);
      if (!$departements){
        $departements = Departement::where('region_id', '=', $code_region)->get();
        Cache::forever('departements_find_by_region_' . $code_region, $departements);
      }
    }
    else {
      $departements = array();
    }
    return Response::eloquent($departements);
  }

  public function get_find($code_departement) {
    if (is_numeric($code_departement)){
      $departement = Departement::find($code_departement);

      if (is_null($departement)){
        return Response::json('Departement not found', 404);
      }
    }
    else {
      return Response::json('Invalid parameter', 500);
    }
    return Response::eloquent($departement);
  }

  public function get_comparer() {
    $departements = array();

    if (array_key_exists("id", $_GET)) {
      $ids = $_GET["id"];
      $departements = Cache::get('departements_comparer_' . implode ('-', $ids));
      if (!$departements){
        $departements_data = Departement::where_in('id', $ids)->get();

        foreach ($departements_data as $departement){
          $departements[$departement->id] = $departement;
        }
        Cache::forever('departements_comparer_' . implode ('-', $ids), $departements);
      }
    }

    return Response::eloquent($departements);
  }

  public function get_liste() {
    $departements = Cache::get('departements_liste');
    if (!$departements){
      $departements = Departement::where("id", ">", "0")->order_by('nom', 'asc')->get(array('id', 'nom'));
      Cache::forever('departements_liste', $departements);
    }
    return Response::eloquent($departements);
  }
}