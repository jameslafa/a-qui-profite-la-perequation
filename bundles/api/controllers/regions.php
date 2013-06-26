<?php

class Api_Regions_Controller extends Base_Controller {

  public $restful = true;

  public function get_find($region_id) {
    if (is_numeric($region_id)) {
      $regions = Cache::get('regions_find_' . $region_id);
      if (!$regions){
        $regions = Region::find($region_id);
        Cache::forever('regions_find_' . $region_id, $regions);
      }
    }
    else {
      $regions = Cache::get('regions_find_all');
      if (!$regions){
        $regions = Region::all();
        Cache::forever('regions_find_all', $regions);
      }
    }
    return Response::eloquent($regions);
  }

  public function get_comparer() {
    $regions = array();

    if (array_key_exists("id", $_GET)) {
      $ids = $_GET["id"];
      $regions = Cache::get('regions_comparer_' . implode ('-', $ids));
      if (!$regions){
        $regions_data = Region::where_in('id', $ids)->get();

        foreach ($regions_data as $region){
          $regions[$region->id] = $region;
        }
        Cache::forever('regions_comparer_' . implode ('-', $ids), $regions);
      }
    }

    return Response::eloquent($regions);
  }

  public function get_liste() {
    $regions = Cache::get('regions_liste');
    if (!$regions){
      $regions = Region::where("id", ">", "0")->order_by('nom', 'asc')->get(array('id', 'nom'));
      Cache::forever('regions_liste', $regions);
    }
    return Response::eloquent($regions);
  }

}