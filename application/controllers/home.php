<?php

class Home_Controller extends Base_Controller {

  public function __construct(){

    Asset::container('head')->add('modernizr', 'js/vendor/modernizr-2.6.2-respond-1.1.0.min.js');

    Asset::container('footer')->add('jquery', 'js/vendor/jquery-1.9.1.min.js');

    if (Laravel\Request::is_env('local')) {
      Asset::container('footer')->add('home-js', 'js/home.js', array('jquery'));
    }
    else {
      Asset::container('footer')->add('home-js', 'js/home.min.js', array('jquery'));
    }

    Asset::container('head')->add('bootstrap-css', 'css/bootstrap.min.css');
    Asset::container('head')->add('bootstrap-css-responsive', 'css/bootstrap-responsive.min.css', 'bootstrap-css');
    Asset::container('head')->add('main.css', 'css/screen.css', array('bootstrap-css', 'bootstrap-css-responsive', 'socialcount-css'));

    parent::__construct();
  }

  public function action_intro(){
    return View::make('home.index')
                  ->with('root_url', URL::base());
  }

  public function action_identifier(){
    $url = $_GET["url"];
    // The user is not authorized, let's redirect him to the gazette authentication page
    if (Laravel\Request::is_env('local')) {
      return Redirect::to("http://test.services.lagazettedescommunes.com/users.php/magazette/identification?reserve=1&club=7&Goingto=" . $url);
    }
    else {
      return Redirect::to("http://services.lagazettedescommunes.com/users.php/magazette/identification?reserve=1&club=7&Goingto=" . $url);
    }
  }

  public function action_connect(){
    setcookie('espace_autorises', 'GAZ01|GAZ02|GAZ03|GAZ08|GAZ09', 0, '/');
    return Redirect::to(URL::base());
  }

  public function action_disconnect(){
    setcookie('espace_autorises', '', time() - 1, '/');
    return Redirect::to(URL::base());
  }
}