<?php
use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\session\Session;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\path\Path;

header('Cache-Control: no-store');

$ans = [];

$lang = Ans::REQ('lang', Cart::$conf['lang']['list'], Cart::$conf['lang']['def']);
$token = Ans::REQ('token', 'string', '');
$user = User::fromToken($token);
$submit = ($_SERVER['REQUEST_METHOD'] === 'POST' || Ans::GET('submit', 'bool'));
$admin = $user ? in_array($user['email'], User::$conf['admin']) : false;

return Rest::get( function () use ($ans, $user, $submit, $admin, $lang) {
	$ans['user'] = !empty($user['user_id']);
	$ans['auth'] = !empty($user['email']);
	$ans['admin'] = $admin;
	return Cart::ret($ans, $lang, 'CR001');
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
