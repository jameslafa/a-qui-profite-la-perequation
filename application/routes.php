<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Simply tell Laravel the HTTP verbs and URIs it should respond to. It is a
| breeze to setup your application using Laravel's RESTful routing and it
| is perfectly suited for building large applications and simple APIs.
|
| Let's respond to a simple GET request to http://example.com/hello:
|
|		Route::get('hello', function()
|		{
|			return 'Hello World!';
|		});
|
| You can even respond to more than one URI:
|
|		Route::post(array('hello', 'world'), function()
|		{
|			return 'Hello World!';
|		});
|
| It's easy to allow URI wildcards using (:num) or (:any):
|
|		Route::put('hello/(:any)', function($name)
|		{
|			return "Welcome, $name.";
|		});
|
*/

Route::get('/', 'home@intro');
Route::get('/identifier', 'home@identifier');
/*Route::get('/debug/connect', 'home@connect');
Route::get('/debug/disconnect', 'home@disconnect');*/

Route::get('/comparer/(:any)/(:any?)/(:any?)/(:any?)', 'comparer@index');

Route::get('/(:any)/(:any)/(:any)/(:any?)/(:any?)', 'app@index');


Route::get('/api/regions/(:any)', 'api::regions@find');
Route::get('/api/departements/region/(:num)', 'api::departements@find_by_region');
Route::get('/api/departements/(:any)', 'api::departements@find');
Route::get('/api/intercos/departement/(:any)', 'api::intercos@find_by_departement');
Route::get('/api/intercos/(:any)', 'api::intercos@find');

Route::get('/api/comparer/regions', 'api::regions@comparer');
Route::get('/api/comparer/departements', 'api::departements@comparer');
Route::get('/api/comparer/intercos', 'api::intercos@comparer');

Route::get('/api/liste/regions', 'api::regions@liste');
Route::get('/api/liste/departements', 'api::departements@liste');
Route::get('/api/liste/intercos', 'api::intercos@liste');

Route::filter('pattern: api/departements/*', 'premium');
Route::filter('pattern: api/intercos/*', 'premium');
Route::filter('pattern: api/liste/departements', 'premium');
Route::filter('pattern: api/liste/intercos', 'premium');
Route::filter('pattern: api/comparer/departements*', 'premium');
Route::filter('pattern: api/comparer/intercos*', 'premium');

/*
|--------------------------------------------------------------------------
| Application 404 & 500 Error Handlers
|--------------------------------------------------------------------------
|
| To centralize and simplify 404 handling, Laravel uses an awesome event
| system to retrieve the response. Feel free to modify this function to
| your tastes and the needs of your application.
|
| Similarly, we use an event to handle the display of 500 level errors
| within the application. These errors are fired when there is an
| uncaught exception thrown in the application.
|
*/

Event::listen('404', function()
{
	return Response::error('404');
});

Event::listen('500', function()
{
	return Response::error('500');
});

/*
|--------------------------------------------------------------------------
| Route Filters
|--------------------------------------------------------------------------
|
| Filters provide a convenient method for attaching functionality to your
| routes. The built-in before and after filters are called before and
| after every request to your application, and you may even create
| other filters that can be attached to individual routes.
|
| Let's walk through an example...
|
| First, define a filter:
|
|		Route::filter('filter', function()
|		{
|			return 'Filtered!';
|		});
|
| Next, attach the filter to a route:
|
|		Route::get('/', array('before' => 'filter', function()
|		{
|			return 'Hello World!';
|		}));
|
*/

Route::filter('before', function()
{
	// Do stuff before every request to your application...
});

Route::filter('after', function($response)
{
	// Do stuff after every request to your application...
});

Route::filter('csrf', function()
{
	if (Request::forged()) return Response::error('500');
});

Route::filter('auth', function()
{
	if (Auth::guest()) return Redirect::to('login');
});


Route::filter('premium', function(){
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

  if (!$authorized){
    return Response::make('Réservé aux membres du Club Finance', 403);
  }
});