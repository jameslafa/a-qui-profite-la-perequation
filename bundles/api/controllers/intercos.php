<?php

class Api_Intercos_Controller extends Base_Controller {

  public $restful = true;

  public function get_find_by_departement($code_departement) {
    if (is_numeric($code_departement) || $code_departement == "2A" || $code_departement == "2B"){
      $intercos = Cache::get('intercos_find_by_departement_' . $code_departement);
      if (!$intercos){
        $intercos = Interco::where('departement_id', '=', $code_departement)->get();
        Cache::forever('intercos_find_by_departement_' . $code_departement, $intercos);
      }
    }
    else {
      $intercos = array();
    }
    return Response::eloquent($intercos);
  }

  public function get_find($code_interco) {
    if (is_numeric($code_departement) || $code_departement == "2A" || $code_departement == "2B"){
      $interco = Interco::find($code_interco);

      if (is_null($interco)){
        return Response::json('Interco not found', 404);
      }
    }
    else {
      return Response::json('Invalid parameter', 500);
    }
    return Response::eloquent($interco);
  }

  public function get_comparer() {
    $intercos = array();

    if (array_key_exists("id", $_GET)) {
      $ids = $_GET["id"];
      $intercos = Cache::get('intercos_comparer_' . implode ('-', $ids));
      if (!$intercos){
        $intercos_data = Interco::where_in('id', $ids)->get();

        foreach ($intercos_data as $interco){
          $intercos[$interco->id] = $interco;
        }
        Cache::forever('intercos_comparer_' . implode ('-', $ids), $intercos);
      }
    }

    return Response::eloquent($intercos);
  }

  public function get_liste() {
    $intercos = NULL;
    if (array_key_exists("departement_id", $_GET)) {
      $id = $_GET["departement_id"];
      $intercos = Cache::get('intercos_liste_' . $id);
      if (!$intercos){
        $intercos = Interco::where("departement_id", "=", $id)->order_by('nom', 'asc')->get(array('id', 'nom'));
        Cache::forever('intercos_liste_' . $id, $intercos);
      }
    }

    return Response::eloquent($intercos);
  }
}