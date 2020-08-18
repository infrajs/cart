<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\mail\Mail;
use akiyatkin\showcase\Showcase;
use infrajs\path\Path;

//Связи и следствия, если одно, то и другие обработки

if (!isset($meta['actions'][$action])) return Cart::fail($ans, $lang, 'CR001.1');
$handlers = $meta['actions'][$action]['handlers']??[];



if (!empty($handler['freeze'])) {
	if (empty($handlers['rule'])) return Cart::fail($ans, $lang, 'CR018.6H');
}
if (!empty($handler['unfreeze'])) {
	if (empty($handlers['rule'])) return Cart::fail($ans, $lang, 'CR018.7H');
}
if (!empty($handlers['status'])) {
	if (empty($handlers['rule'])) return Cart::fail($ans, $lang, 'CR018.4H');
}
if (!empty($handlers['rule'])) {
	if (empty($handlers['order'])) return Cart::fail($ans, $lang, 'CR018.5H');
}



// Подготовительный блок согласно meta.json
if (!empty($handlers['post'])) {
	$submit = ($_SERVER['REQUEST_METHOD'] === 'POST' || Ans::GET('submit', 'bool'));
	if (!$submit) return Cart::fail($ans, $lang, 'CR007.1H');
}
if (!empty($handlers['admin'])) {
	if (empty($user['admin'])) return Cart::fail($ans, $lang, 'CR003.1');
}

if (!empty($handlers['model'])) {
	$model_id = Ans::REQ('model_id');
	if (!$model_id) return Cart::fail($ans, $lang, 'CR016.1');
	$item_num = Ans::REQ('item_num', 'int', 1);
	$catkit = Ans::REQ('catkit', 'string', '');
	$pos = [
		'model_id' => $model_id,
		'item_num' => $item_num,
		'catkit' => $catkit
	];
	$model = Cart::getFromShowcase($pos);
	if (!$model) return Cart::fail($ans, $lang, 'CR013.1');

	if (empty($model['Цена'])) return Cart::fail($ans, $lang, 'CR014.1');
}

if (!empty($handlers['order'])) {
	$order_id = Ans::REQ('order_id');
	$order_nick = Ans::REQ('order_nick');
	if (!is_null($order_id)) {
		$order = Cart::getById($order_id);
	} elseif (!is_null($order_nick)) {
		$order = Cart::getByNick($order_nick);
	}
	if (!is_null($order_id) || !is_null($order_nick)) {
		if (!$order) return Cart::fail($ans, $lang, 'CR004.1');
	}
	if ($order) {
		//Можно работать только со своими заявками, если ты не админ конечно
		if (empty($user['admin']) && !Cart::isOwner($order, $user)) return Cart::err($ans, $lang, 'CR003.2');
	}
}
if (!empty($handlers['rule'])) {

	// if (!$order) { //Если заявки нет, найти заявку у текущего пользователя
	// 	if (!$user) return Cart::fail($ans, $lang, 'CR017.2');
	// 	$order = Cart::getActiveOrder($user);
	// 	//if (!$order) return Cart::fail($ans, $lang, 'CR004.2H');
	// }
	if (!$order) { //Если заявки нет, найти заявку у текущего пользователя, если пользователя нет - создать, если заявки нет - создать.
		if (!$user) {
			$user = User::create();
			if (!$user) return Cart::fail($ans, $lang, 'CR009.1');
			$ans['token'] = $user['user_id'] . '-' . $user['token'];
		} else {
			$order = Cart::getActiveOrder($user);
		}
		if (!$order) $order = Cart::create($user);
		if (!$order) return Cart::fail($ans, $lang, 'CR008.1');
	}
	if (!isset($rules[$order['status']])) return Cart::fail($ans, $lang, 'CR018.1H');
	$rule = $rules[$order['status']];
}
if (!empty($handlers['paid'])) {
	if ($order['paid']) return Cart::fail($ans, $lang, 'CR056.1H');
}
if (!empty($handlers['status'])) {
	if ($order['status'] === $action) return Cart::fail($ans, $lang, 'CR031.1H');
	if (is_array($order['status']) && empty($user['admin']) && !in_array($order['status'], $handlers['status'])) return Cart::fail($ans, $lang, 'CR031.2H');
}
if (!empty($handlers['checkdata'])) {
	if (empty($order['email'])) return Cart::err($ans, $lang, 'CR005.2');
	if (empty($order['basket'])) return Cart::err($ans, $lang, 'CR020.1');
	if (empty($order['name'])) return Cart::err($ans, $lang, 'CR026.2H');
}
if (!empty($handlers['ouser'])) {
	if (empty($order['email'])) return Cart::fail($ans, $lang, 'CR018.2H');
	$ouser = User::getByEmail($order['email']);
	if (empty($ouser)) return Cart::fail($ans, $lang, 'CR018.3H');
}
if (!empty($handlers['fuser'])) {
	$user_id = Ans::REQ('user_id', 'int', null);
	$email = Ans::REQ('email');
	if (!is_null($user_id)) {
		$fuser = User::getById($user_id);
	} else if (!is_null($email)) {
		if (!Mail::check($email)) return Cart::err($ans, $lang, 'CR005.1');
		$fuser = User::getByEmail($email);
	}
	if (!is_null($user_id) || !is_null($email)) {
		if (!$fuser) return Cart::fail($ans, $lang, 'CR017.1');
	}

	if ($fuser) {
		//Можно работать только с данными своего пользователя, если ты не админ конечно
		if (empty($user['admin']) && (!$user || $fuser['user_id'] !== $user['user_id'])) return Cart::err($ans, $lang, 'CR003.3');
	}
}

if (!empty($handlers['freeze'])) {
	if (!Cart::freeze($order)) return Cart::fail($ans, $lang, 'CR018.12H');
}
if (!empty($handlers['unfreeze'])) {
	if (!Cart::unfreeze($order)) return Cart::fail($ans, $lang, 'CR018.13H');
}
