<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\mail\Mail;
use akiyatkin\city\City;
use akiyatkin\showcase\Showcase;
use infrajs\path\Path;
use infrajs\db\Db;
use infrajs\lang\Lang;

//Связи и следствия, если одно, то и другие обработки

if (!isset($meta['actions'][$action])) return Cart::fail($ans, $lang, 'CR001.h'.__LINE__);
$handlers = $meta['actions'][$action]['handlers'] ?? [];

if (!empty($handlers['goal'])) {
	$ans['goal'] = $handlers['goal'];
}
if (empty($handlers['rule'])) {
	//Опции действуют только с rule
	if (!empty($handler['freeze'])) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
	if (!empty($handler['unfreeze'])) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
	if (!empty($handlers['status'])) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
	if (!empty($handlers['payd'])) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
	if (!empty($handlers['checkdata'])) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
}

if (!empty($handlers['rule'])) {
	//rule создаёт заявку и пользователя если их нет
	//Обязательные опции для rule
	$handlers['order'] = true;
	//$handlers['ouser'] = true;
	$handlers['post'] = true;
}

if (!empty($handlers['edit'])) {
	$handlers['paid'] = true;
}

// Подготовительный блок согласно meta.json

if (!empty($handlers['post'])) {
	$submit = ($_SERVER['REQUEST_METHOD'] === 'POST' || Ans::GET('submit', 'bool'));
	if (!$submit) return Lang::fail($ans, $lang, 'lang.post.h'.__LINE__);
}

if (!empty($handlers['admin'])) {
	if (empty($user['admin'])) return Cart::fail($ans, $lang, 'CR003.h'.__LINE__);
}

// if (!empty($handlers['email'])) {
// 	$email = Ans::REQ('email');
// 	if (!Mail::check($email)) return Cart::err($ans, $lang, 'CR005.2H');
// }


if (!empty($handlers['model'])) {
	$model_id = Ans::REQ('model_id');
	$position_id = Ans::REQ('position_id');
	if (!$model_id && !$position_id) return Cart::fail($ans, $lang, 'posmod.h'.__LINE__);
	if ($position_id) {
		$sql = 'SELECT model_id, item_num, catkit from cart_basket where position_id = :position_id';
		$row = Db::fetch($sql, [
			':position_id'=> $position_id
		]);
		if (!$row) return Cart::fail($ans, $lang, 'posmod.h'.__LINE__);
		extract($row);
	}
	if ($model_id) {
		$item_num = Ans::REQ('item_num', 'int', 1);
		$catkit = Ans::REQS('catkit', 'string', '');
		$pos = [
			'model_id' => $model_id,
			'item_num' => $item_num,
			'catkit' => $catkit
		];
	}
	$model = Cart::getFromShowcase($pos);

	if (!$model) return Cart::fail($ans, $lang, 'CR013.h'.__LINE__);

	if (empty($model['Цена'])) return Cart::fail($ans, $lang, 'CR014.h'.__LINE__);
}


if (!empty($handlers['order'])) {
	$order_id = Ans::REQ('order_id');
	if ($order_id === 'active') $order_id = null;

	$order_nick = Ans::REQS('order_nick');
	if ($order_nick === 'active') $order_nick = null;
	if (!is_null($order_id)) {
		$order = Cart::getById($order_id);
	} elseif (!is_null($order_nick)) {
		$order = Cart::getByNick($order_nick);
	}
	if (!is_null($order_id) || !is_null($order_nick)) {
		if (!$order) return Cart::fail($ans, $lang, 'CR004.h'.__LINE__);
	}
	
	if ($order) {
		//Можно работать только со своими заявками, если ты не админ конечно
		if (empty($user['admin']) && !Cart::isOwner($order, $user)) return Cart::err($ans, $lang, 'CR003.h'.__LINE__);
	}
}

if (!empty($handlers['rule'])) {

	$city_id = Ans::REQ('city_id', 'int', null);
	if (is_null($city_id)) return Cart::fail($ans, $lang, 'CR058.h'.__LINE__);
	
	$timezone = Ans::REQS('timezone', 'string', null); //Intl.DateTimeFormat().resolvedOptions().timeZone (Asia/Dubai)
	if (is_null($timezone)) return User::fail($ans, $lang, 'U036.h'.__LINE__);
	
	if (!$order) {
		if (!$user) {
			$city = City::getById($city_id, $lang);
			if (!$city) return Cart::fail($ans, $lang, 'CR059.h'.__LINE__);

			$user = User::create($lang, $city['city_id'], $timezone);
			if (!$user) return Cart::fail($ans, $lang, 'CR009.h'.__LINE__);
			$ans['token'] = $user['user_id'] . '-' . $user['token'];
		} else {
			$order = Cart::getActiveOrder($user);
		}
		if (!$order) $order = Cart::create($user);
		if (!$order) return Cart::fail($ans, $lang, 'CR008.h'.__LINE__);
	}
	if (!isset($rules[$order['status']])) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
	$rule = $rules[$order['status']];

	if (!empty($handlers['paid'])) {
		if ($order['paid']) return Cart::fail($ans, $lang, 'CR056.h'.__LINE__);
	}
	
	//У действия или должен быть статус с кем оно работает или оно должно быть в списке действий с заказом
	if (!empty($handlers['edit'])) {
		//Некоторые действия считаются edit и не могут выполняться без нужного разрешения
		if (empty($rule['actions'][$place]['edit'])) return Cart::fail($ans, $lang, 'CR003.h'.__LINE__);
	}

	//С заказами каким статусом можно выполнить действие. Указывается если действия нет в списке действий со статусом заказа
	if (!empty($handlers['status'])) {
		if ($order['status'] === $action) return Cart::fail($ans, $lang, 'CR031.h'.__LINE__);
		//if (is_array($order['status']) && empty($user['admin']) && !in_array($order['status'], $handlers['status'])) return Cart::fail($ans, $lang, 'CR031.h'.__LINE__);

		if (!in_array($order['status'], $handlers['status'])) return Cart::fail($ans, $lang, 'CR031.h'.__LINE__);

	}
	if (empty($handlers['status']) && empty($handlers['edit']) && empty($handlers['admin'])) {
		$actions = [];
		if (!empty($rule['actions'][$place])) {
			$obj = $rule['actions'][$place];
			if (isset($obj['actions'])) $actions += $obj['actions'];
			if (isset($obj['buttons'])) $actions += array_keys($obj['buttons']);
		}
		$actions = array_unique($actions);
		//$rule['actions'][$place]['actions'] = $actions;
		if (!in_array($action, $actions))  return Cart::fail($ans, $lang, 'CR003.h'.__LINE__);
	}

	

	if (!empty($handlers['checkdata'])) {
		if (empty($order['basket'])) return Cart::err($ans, $lang, 'CR020.h'.__LINE__);
		if (empty($order['name'])) return Cart::err($ans, $lang, 'CR026.h'.__LINE__);
		if (empty($order['phone'])) return Cart::err($ans, $lang, '5.h'.__LINE__);
		if (empty($order['email'])) return Cart::err($ans, $lang, 'CR005.h'.__LINE__);
	}
}


// if (!empty($handlers['ouser'])) {
// 	if (empty($order['email'])) {
// 		$ouser = $user;
// 	} else {
// 		$ouser = User::getByEmail($order['email']);
// 		//if (empty($ouser)) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
// 		if (empty($ouser)) $ouser = $user;
// 	}
// }

if (!empty($handlers['fuser'])) {
	$user_id = Ans::REQ('user_id', 'int', null);
	$email = Ans::REQS('email');
	if (!is_null($user_id)) {
		$fuser = User::getById($user_id);
	} else if (!is_null($email)) {
		if (!Mail::check($email)) return Cart::err($ans, $lang, 'CR005.h'.__LINE__);
		$fuser = User::getByEmail($email);
	}
	if (!is_null($user_id) || !is_null($email)) {
		if (!$fuser) return Cart::fail($ans, $lang, 'CR017.h'.__LINE__);
	}

	if ($fuser) {
		//Можно работать только с данными своего пользователя, если ты не админ конечно
		if (empty($user['admin']) && (!$user || $fuser['user_id'] !== $user['user_id'])) return Cart::err($ans, $lang, 'CR003.h'.__LINE__);
	}
}

if (!empty($handlers['freeze'])) {
	if (!Cart::freeze($order)) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
}
if (!empty($handlers['unfreeze'])) {
	if (!Cart::unfreeze($order)) return Cart::fail($ans, $lang, 'CR018.h'.__LINE__);
}


if (!empty($handlers['savedataifruleedit'])) {
	//Разрешено редактирование данных и сохраняем данные из полей
	if (!empty($rule['actions'][$place]['edit'])) {
		
	}
}
