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
use infrajs\nostore\Nostore;

Nostore::on();
	
$context = new Meta([
	'src' => '-cart/api/meta.json',
	'action' => Rest::first(),
	'name' => 'cart', 
	'lang' => Cart::$conf['lang']['def']
]);
include(Path::theme(Rest::getRoot() . '/args.php'));
include(Path::theme(Rest::getRoot() . '/vars.php'));
include(Path::theme(Rest::getRoot() . '/handlers.php'));
include(Path::theme(Rest::getRoot() . '/actions.php'));


return $context->init();




