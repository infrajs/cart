<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\path\Path;
use infrajs\db\Db;
use infrajs\mail\Mail;
use akiyatkin\city\City;
use akiyatkin\showcase\Showcase;
use infrajs\lang\Lang;
use infrajs\access\Access;
use infrajs\cart\api\Meta;


	
$context = new Meta([
	'src' => '-cart/api/meta.json',
	'name' => 'cart', 
	'lang' => Cart::$conf['lang']['def']
]);
include(Path::theme(Rest::getRoot() . '/args.php'));
include(Path::theme(Rest::getRoot() . '/vars.php'));
include(Path::theme(Rest::getRoot() . '/handlers.php'));
include(Path::theme(Rest::getRoot() . '/actions.php'));


return $context->init();




