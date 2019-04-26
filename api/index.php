<?php
use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\session\Session;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\path\Path;

return Rest::get( function () {
	echo 'order';
}, 'order', function ($type, $id = ''){
	$ans = [];
	$orderid = $id;
	if ($orderid == 'my') $orderid = '';
	if (!Cart::canI($orderid)) {
		return Ans::err($ans, 'У вас нет доступа к этому разделу.');
	}
	$ans['order'] = Cart::getGoodOrder($orderid);
	if (Session::getId()) {
		$ans['user'] = User::get();
	}
	$ans['manager'] = Session::get('safe.manager'); 
	return Ans::ret($ans);
}, function (){
	echo 'order';
});
