<?php

use infrajs\cart\Cart;
use infrajs\user\User;
use infrajs\rest\Rest;
use infrajs\ans\Ans;
use infrajs\load\Load;

use infrajs\mail\Mail;
use infrajs\db\Db;
use akiyatkin\showcase\Showcase;
use akiyatkin\city\City;
use infrajs\path\Path;
use infrajs\cart\cdek\CDEK;
use infrajs\cart\pochta\Pochta;

// Обработка actions
if ($action == 'check' || $action == 'paykeeper') {
	//Проверяем email в заказе и создаём пользователя

	$email = $order['email'];
	//$order['user'] - это тот кому принадлежит заказ, может отличаться от указанного email
	$ouser = User::getByEmail($email); // это тот чей email указан в заказе
	if (!$ouser) { //Пользователя нет с указанным email в заказе
		if ($user['email']) { //У текущего пользователя есть email и мы его не можем поменять
			$ouser = User::create($lang, $city_id, $timezone, $email); //Создаём нового пользователя, чтобы запомнить что у него есть заказ
		} else { //Если у текущего пользователя не было email устанавливаем его
			$ouser = $user; // и теперь это один и тотже пользователь
			User::setEmail($user, $email); //должно быть событие о появлении email Global.set('user')
		}
		$ans['token'] = $ouser['user_id'] . '-' . $ouser['token'];
	} else { //Если на указанный email уже есть регистрация
		if ($ouser['user_id'] != $user['user_id']) { //и это не мы
			
			if (empty($user['email'])) { 
				//Текущий пользователь не зарегистрирован, ему нужно просто перейти в свой аккаунт
				$ouser['order'] = $order;
				$r = User::mail($ouser, $userlang, 'userdata', '/cart/orders/active');
				if (!$r) return Cart::err($ans, $lang, 'CR023.a' . __LINE__);
				return Cart::err($ans, $lang, 'CR022.a' . __LINE__);	
			} else {
				//У текущего пользователя есть аккаунт, ему не надо переходить, но нужно дать доступ и пользователю по указанному email
				//Передаём доступ к текущему заказу и на этот аккаунт и делает для нового аккаунта этот заказ активным?. Злоумышленник кому-то может подсунуть новый заказ)
				Cart::setOwner($order, $ouser);
				//И пропускаем оформление заказа дальше
			}
			
		}
	}	
	$r = Cart::setOwner($order, $ouser);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	Cart::recalc($order['order_id']);
	$order = Cart::getById($order['order_id']);
}

if ($action == 'check') {
	

	if (!Cart::setStatus($order, 'check')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	//$ouser = $order['user'];
	$ouser['order'] = $order;
	if (!$silence) {
		if ($place == 'orders') {
			Cart::mailtoadmin($ouser, $lang, 'AdmOrderToCheck');
		}
		Cart::mail($ouser, $lang, 'orderToCheck');
	}

	//После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
	$r = Cart::resetActive($order);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

	$worder = Cart::getWaitOrder($ouser);
	if ($worder) {
		$r = Cart::setActive($worder['order_id'], $ouser['user_id']);
		if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	}

	return Cart::ret($ans, $lang, 'CR025.a' . __LINE__);
} elseif ($action == 'estimate') {
	$city = City::getById($city_id, $lang);
	$zip = $city['zip'];
	
	$ans['city'] = $city;
	$model = Showcase::getModel($producer_nick, $article_nick);
	if (!$model) return Cart::fail($ans, $lang, 'CR013.a'.__LINE__);
	$weight = Cart::getWeight($model);
	if (!$weight) return Cart::err($ans, $lang, 'posweight.a'.__LINE__);
	
	$transports = Cart::$conf['transports'];
	
	$ans['transports'] = [];

	$ans['transports']['pochta'] = [];
	foreach(['pochta_simple','pochta_1','pochta_courier'] as $type) {
		if (!in_array($type, $transports)) continue;
		$res = Pochta::calc($type, $weight, $zip);
		if ($res) $ans['transports']['pochta'][$type] = $res;
	}
	if (!$ans['transports']['pochta']) unset($ans['transports']['pochta']);

	$dim = CDEK::getDim($model);
	$ans['dim'] = $dim;
	$goods = [$dim];
	$ans['transports']['cdek'] = [];
	$convert = ['cdek_pvz' => 'pickup', 'cdek_courier' => 'courier'];
	foreach(['cdek_pvz','cdek_courier'] as $type) {
		if (!in_array($type, $transports)) continue;
		$res = CDEK::calc($goods, $convert[$type], $city_id);
		if ($res) $ans['transports']['cdek'][$type] = $res;
	}
	if (!$ans['transports']['cdek']) unset($ans['transports']['cdek']);

	return Cart::ret($ans);

} elseif ($action == 'paykeeper') {
	if (!Cart::setStatus($order, 'pay')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	//После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
	$r = Cart::resetActive($order);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans, $lang, 'pay3.a' . __LINE__);

} elseif ($action == 'tocheck') {
	$email = $order['email'];
	$ouser = User::getByEmail($email);
	
	if (!Cart::setStatus($order, 'check', true)) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans, $lang, 'CR025s.a' . __LINE__);

// } elseif ($action == 'edit') {
// 	$email = Ans::REQ('email');
// 	if (!Mail::check($email)) return Cart::err($ans, $lang, 'CR005.a' . __LINE__);

// 	$phone = Ans::REQ('phone');
// 	if ((strlen($phone) < 7 || strlen($phone) > 30)) return Cart::err($ans, $lang, '5.a' . __LINE__);

// 	$name = Ans::REQ('name');
// 	if ((strlen($name) < 2 || strlen($name) > 150)) return Cart::err($ans, $lang, 'CR026.a' . __LINE__);

// 	$comment = Ans::REQ('comment', 'string', '');
// 	$address = Ans::REQ('address', 'string', '');
// 	$zip = Ans::REQ('zip', 'string', '');

// 	$city = City::getById($city_id, $lang);
// 	if (!$city) return Cart::fail($ans, $lang, 'CR059.a'.__LINE__);

// 	$ouser = User::getByEmail($email);
// 	if (!$ouser) {
// 		//Создать пользователя может и админ и просто пользователь на свободный email
// 		//Пользователь остаётся в своей авторизации если она есть
		
// 		$ouser = User::create($lang, $city['city_id'], $timezone, $email); //Создаём пользователя на указанный в заказе email и навязываем своё окружение
// 		if (!$ouser) return Cart::fail($ans, $lang, 'CR009.a' . __LINE__);
// 		//Авторизуемся если ещё нет
// 		if (!$user) $ans['token'] = $ouser['user_id'] . '-' . $ouser['token'];
// 	} else {
// 		if ($ouser['user_id'] == $user['user_id']) {
// 			$r = User::setEnv($ouser, $timezone, $lang, $city['city_id']);
// 			if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
// 		}
// 		if ($ouser['user_id'] != $user['user_id'] && empty($user['admin'])) {
// 			//Если на указанный email есть регистрация и это не я. Админ может указывать любой ящик без авторизации и приписать ему заказ
// 			$ouser['order'] = $order;
// 			$r = User::mail($ouser, $userlang, 'userdata', '/cart/orders/' . $order['order_nick']);
// 			if (!$r) return Cart::ret($ans, $lang, 'CR023.a' . __LINE__);
// 			return Cart::ret($ans, $lang, 'CR022.a' . __LINE__);
// 		}
// 	}

// 	$r = Cart::edit($order, [
// 		':phone' => $phone,
// 		':comment' => $comment,
// 		':address' => $address,
// 		':zip' => $zip,
// 		':email' => $email,
// 		':name' => $name
// 	]);
// 	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

// 	$order = Cart::getById($order['order_id']);
// 	$r = Cart::setOwner($order, $ouser);
// 	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

// 	if ($place == 'orders') {
// 		$r = Cart::setActive($order, $ouser);
// 		if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
// 	}


// 	return Cart::ret($ans, $lang, 'CR024.a' . __LINE__);
} elseif ($action == 'setcallback') {
	$callback = Ans::REQ('callback', ['yes', 'no', ''], null);
	if (is_null($callback)) return Cart::fail($ans, $lang, 'callback.a' . __LINE__);
	$r = Cart::setCallback($order, $callback);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans);
} elseif ($action == 'years') {
	$years = Cart::getYears();
	$ans['years'] = $years;
	return Cart::ret($ans);
} elseif ($action == 'meta') {

	$ans['meta'] = Cart::getJsMeta($meta, $lang);
	return Cart::ret($ans);
} elseif ($action == 'complete') {
	if (!Cart::setStatus($order, 'complete')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	//После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
	$r = Cart::resetActive($order);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans, $lang, 'CR040.a' . __LINE__);


} elseif ($action == 'setcommentmanager') {
	$commentmanager = Ans::REQS('commentmanager', 'string', '');
	if (!$commentmanager) return Cart::fail($ans, $lang, 'CR063.a' . __LINE__);
	$r = Cart::setCommentManager($order, $commentmanager);

	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
} elseif ($action == 'email') {
	$commentmanager = Ans::REQS('commentmanager', 'string', '');
	if (!$commentmanager) return Cart::fail($ans, $lang, 'CR063.a' . __LINE__);
	$order['commentmanager'] = $commentmanager;
	$r = Cart::setCommentManager($order, $commentmanager);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	$ouser = User::getByEmail($order['email']);
	$ouser['order'] = $order;
	if (!$silence) {
		$r = Cart::mail($ouser, $lang, 'email');
		if (!$r) return Cart::fail($ans, $lang, 'CR018.a7');
	}
	Cart::setEmailDate($order);
	return Cart::ret($ans, $lang, 'CR055.A1');
} elseif ($action == 'wait') {
	if (!Cart::setStatus($order, 'wait')) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	
	$fuser = User::getByEmail($order['email']);
	if (!$fuser) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	Cart::setActive($order['order_id'], $fuser['user_id']);
	if ($fuser != $user && $place == 'orders') Cart::setActive($order['order_id'], $user['user_id']);

	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans, $lang, 'CR030.a' . __LINE__);
} elseif ($action == 'delete') {
	$r = Cart::delete($order);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans, $lang, 'CR027.a' . __LINE__);
} elseif ($action == 'remove') {
	$position_ids = Ans::REQ('position_ids', 'string'); //Через запятую
	if (!$position_ids) return Cart::fail($ans, $lang, 'CR033.a' . __LINE__);
	$position_ids = explode(',', $position_ids);
	foreach ($position_ids as $i => $id) {
		$position_ids[$i] = (int) $id;
		if (!$position_ids[$i]) return Cart::fail($ans, $lang, 'CR033.a' . __LINE__);
	}
	$r = Cart::removePos($position_ids);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	if (sizeof($position_ids) > 1) {
		return Cart::ret($ans, $lang, 'CR057.a' . __LINE__);
	} else {
		return Cart::ret($ans, $lang, 'CR034.a' . __LINE__);
	}
} elseif ($action == 'clear') {
	if (!Cart::clear($order)) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans, $lang, 'CR037.a' . __LINE__);
} elseif ($action == 'add') {
	$count = Ans::REQ('count', 'int', 1);
	$r = Cart::add($order, $model, $count);
	if (!$r) return Cart::fail($ans, $lang, 'CR015.a' . __LINE__);
	return Cart::ret($ans, $lang, 'CR029.a' . __LINE__);
} elseif ($action == 'freezeall') {
	$orders = Db::colAll('SELECT order_id from cart_orders where freeze = 1');
	foreach ($orders as $order_id) {
		Cart::freeze($order_id);
	}

	return Cart::ret($ans, $lang, 'Выполнена повторная заморозка');

} elseif ($action == 'addremove') {
	$count = Ans::REQ('count', 'int', false);
	if (!$count) $count = false;

	$r = Cart::add($order, $model, $count);
	if (!$r) return Cart::fail($ans, $lang, 'CR015.a' . __LINE__);
	if ($count) return Cart::ret($ans, $lang, 'CR029.a' . __LINE__);
	else return Cart::ret($ans, $lang, 'CR034.a' . __LINE__);
} elseif ($action == 'setlang') {
	//Вызывается для активного заказа при изменении языка на сайте
	//rules, $order, $lang уже есть надо его сохранить
	$r = Cart::setLang($order, $lang);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans);
} elseif ($action == 'setcoupon') {
	$coupon = Ans::REQS('coupon');
	$coupondata = Load::loadJSON('-cart/coupon?name=' . $coupon);
	$r = Cart::setCoupon($order, $coupon, $coupondata);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	//return Cart::fail($ans, $lang, 'badcoupon.a' . __LINE__);
	return Cart::ret($ans);

} elseif ($action == 'setcity') {
	//При изменении города пересчитывается корзина. Стоимость доставки будет другой.

	$r = Cart::setCity($order, $city_id);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans);

} elseif ($action == 'setcomment') {
	$comment = Ans::REQS('comment','string','');
	$r = Db::exec('UPDATE cart_orders
		SET comment = :comment, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':comment' => $comment
	]) !== false;
	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
} elseif ($action == 'setzip') {
	$zip = Ans::REQ('zip','int','');
	if ($zip && strlen($zip)!=6) return Cart::err($ans, $lang, 'zip.a' . __LINE__);
	$r = Db::exec('UPDATE cart_orders
		SET zip = :zip, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':zip' => $zip
	]) !== false;
	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

} elseif ($action == 'setaddress') {
	$address = Ans::REQS('address');
	$err = !$address || strlen($address) < 6 || strlen($address) > 200;
	if ($err) $address = '';
	$r = Db::exec('UPDATE cart_orders
		SET address = :address, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':address' => $address
	]) !== false;
	if ($err) return Cart::err($ans, $lang, 'address.a' . __LINE__);
	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
} elseif ($action == 'setname') {
	$name = Ans::REQS('name');
	$err = (!$name || strlen($name) < 3 || strlen($name) > 200);
	if ($err) $name = '';
	$r = Db::exec('UPDATE cart_orders
		SET name = :name, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':name' => $name
	]) !== false;
	if ($err) return Cart::err($ans, $lang, 'CR026.a' . __LINE__);
	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
} elseif ($action == 'setphone') {
	$phone = Ans::REQS('phone');
	$err = !$phone || strlen($phone) < 3 || strlen($phone) > 30;
	if ($err) $phone = '';
	$r = Db::exec('UPDATE cart_orders
		SET phone = :phone, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':phone' => $phone
	]) !== false;
	if ($err) return Cart::err($ans, $lang, '5.a' . __LINE__);
	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
} elseif ($action == 'setemail') {
	$email = Ans::REQS('email');
	$err = !Mail::check($email);
	if ($err) $email = '';
	$r = Db::exec('UPDATE cart_orders
		SET email = :email, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':email' => $email
	]) !== false;
	if ($err) return Cart::err($ans, $lang, 'CR005.a' . __LINE__);
	return $r ? Cart::ret($ans, $lang, 'saved.a'.__LINE__) : Cart::fail($ans, $lang, 'CR018.a' . __LINE__);

} elseif ($action == 'mystat') {
	$ans['count'] = 0;
	if ($user) {
		$order_id = Cart::getActiveOrderId($user['user_id']);
		if ($order_id) {
			$basket = Db::all('SELECT position_id, discount, count from cart_basket where order_id = :order_id', [
				':order_id' => $order_id
			]);
			$sum = 0;
			$count = 0;
			foreach ($basket as $pos) {
				$model = Cart::getModel($pos['position_id']);
				if (!$model) continue;
				$count++;
				$discount = 1 - $pos['discount'] / 100;
				$sum += $model['Цена'] * $discount * $pos['count'];
			}
			$ans['sum'] = $sum;
			$ans['count'] = $count;
		}
	}
	return Cart::ret($ans);
} elseif ($action == 'setcdek') {

	$pvz = Ans::REQ('pvz','string','');
	if (!$pvz) $pvz = $order['pvz'];
	$transport = Ans::REQ('transport', Cart::$conf['transports']);
	if (!$transport) return Cart::fail($ans, $lang, 'CR060.a' . __LINE__);
	//$city_id
	$r = Db::exec('UPDATE cart_orders
		SET pvz = :pvz, transport = :transport, city_id = :city_id, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':city_id' => $city_id,
		':transport' => $transport,
		':pvz' => $pvz
	]) !== false;
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	Cart::recalc($order['order_id']);
	return Cart::ret($ans);

} elseif ($action == 'setpvz') {
	$pvz = Ans::REQ('pvz');
	if (!$pvz) return Cart::fail($ans, $lang, 'CR060.a' . __LINE__);
	$r = Db::exec('UPDATE cart_orders
		SET pvz = :pvz, dateedit = now()
		WHERE order_id = :order_id
	', [
		':order_id' => $order['order_id'],
		':pvz' => $pvz
	]) !== false;
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans);
} elseif ($action == 'settransport') {
	$transport = Ans::REQ('transport', Cart::$conf['transports'], '');
	//if (!$transport) return Cart::fail($ans, $lang, 'CR060.a' . __LINE__);
	$r = Cart::setTransport($order, $transport);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans);
} elseif ($action == 'setpay') {
	$pay = Ans::REQ('pay', Cart::$conf['pays']);
	//if (!$pay) return Cart::fail($ans, $lang, 'CR062.a' . __LINE__);
	$r = Cart::setPay($order, $pay);
	if (!$r) return Cart::fail($ans, $lang, 'CR018.a' . __LINE__);
	return Cart::ret($ans);

} elseif ($action == 'order') {
	if ($user && $place == 'orders' && !$order) $order = Cart::getActiveOrder($user);
	if (!$order) return Cart::err($ans, $lang, 'empty.a' . __LINE__);
	$ans['rule'] = Cart::getJsMetaRule($meta, $order['status'], $lang);
	$order['city'] = Cart::getCity($order['city_id'], $order['email'], $order['order_id'], $lang);
	$order['city']['zips'] = City::getIndexes($order['city_id']);
	$ans['order'] = $order;
	
	
	$ans['active'] = Cart::isActive($order, $user);
	if (!sizeof($order['basket'])) return Cart::ret($ans, $lang, 'empty.a' . __LINE__);
	//if (!$order['sum']) return Cart::ret($ans, $lang, 'empty.a' . __LINE__);
	return Cart::ret($ans);
} elseif ($action == 'ousers') {
	if (!$order) return Cart::fail($ans, $lang, 'CR002.a' . __LINE__);
	$users = Cart::getUsers($order);
	$ans['users'] = $users;
	return Cart::ret($ans);
} elseif ($action == 'create') {
	if (!$fuser) $fuser = $user;
	if (!$fuser) return Cart::fail($ans, $lang, 'CR017.a' . __LINE__);

	$order = Cart::create($fuser);
	if (!$order) return Cart::fail($ans, $lang, 'CR008.a' . __LINE__);
	$ans['order'] = $order;
	return Cart::ret($ans);
} elseif ($action == 'cart') {
	$status = ''; //Все статусы
	$wait = true; //Нужно ли брать в расчёт ожидающие заказы
	$start = 0;
	$end = time();
	if (!$user) return Cart::err($ans, $lang, 'noorders.a' . __LINE__);
	$list = Cart::getOrders($user, $status, $wait, $start, $end);
	if (!$list) return Cart::err($ans, $lang, 'CR006.a' . __LINE__);
	foreach ($list as $k => $order) {
		$list[$k]['active'] = Cart::isActive($order, $user);
	}
	$ans['list'] = $list;
	$ans['meta'] = Cart::getJsMeta($meta, $lang);
	return Cart::ret($ans);
} elseif ($action == 'orders') {
	$status = Ans::REQ('status', 'string', '');
	$wait = Ans::REQ('wait', 'int', 0); //Нужно ли брать в расчёт ожидающие заказы
	$start = Ans::REQ('start', 'int', 0);
	$ans['wait'] = $wait;
	if (!$start) $start = strtotime('first day of this month 0:0');
	
	$end = strtotime('first day of next month 0:0', $start);
	
	$ans['start'] = $start;
	//$ans['end'] = $end;
	$ans['Y'] = date('Y', $start);
	$ans['F'] = Cart::lang($lang, date('F', $start));
	$ans['startstr'] = date('d.m.Y H:i:s', $start);
	//$ans['endstr'] = date('d.m.Y H:i:s', $end);
	$list = Cart::getOrders($fuser, $status, $wait, $start, $end);
	if (!$list) return Cart::err($ans, $lang, 'CR006.a' . __LINE__);
	

	$total = 0;
	foreach ($list as $k => $order) {
		/*
			Если в заказе не мой email, то изменения города в шапке на заказ не повлияют, так как не будут менять город у пользователя по email.
			При freeze нужно фиксировать город.
		*/

		$list[$k]['city'] = Cart::getCity($order['city_id'], $order['email'], $order['order_id'], $lang);
		$total += $order['total'];
	}
	$ans['list'] = $list;
	$ans['total'] = $total;
	$ans['meta'] = Cart::getJsMeta($meta, $lang);
	return Cart::ret($ans);
} else {
	return Cart::fail($ans, $lang, 'CR001.a' . __LINE__);
}
