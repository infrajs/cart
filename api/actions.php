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


$context->actions = [
	"mystat" => function () {
		extract($this->gets(['ans','basket']), EXTR_REFS);
		$ans['count'] = 0;

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
	},	
	'estimate' => function () {
		extract($this->gets(['ans','city_id', 'city','model']), EXTR_REFS);
		$zip = $city['zip'];
		$ans['city'] = $city;		
		$weight = Cart::getWeight($model);
		if (!$weight) return $this->err('posweight', 'a'.__LINE__);
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
	},	
	'orderfast' => function () {
		extract($this->gets(['ans','order_id']), EXTR_REFS);
		$ans['order'] = Cart::getById($order_id, true);
	},	
	'order' => function () {
		extract($this->gets(['order','user_id', 'user','place','lang','ans']), EXTR_REFS);
		//if ($user && $place == 'orders' && !$order) $order = Cart::getActiveOrder($user_id);
		if (!$order) return $this->err('empty','a' . __LINE__);
		$ans['rule'] = Cart::getJsMetaRule($this->meta, $order['status'], $lang);
		$order['city'] = Cart::getCity($order['city_id'], $order['email'], $order['order_id'], $lang);
		$order['city']['zips'] = City::getIndexes($order['city_id']);
		$ans['order'] = $order;
		$ans['active'] = Cart::isActive($order, $user);
		if (!sizeof($order['basket'])) return $this->ret('empty', 'a' . __LINE__);
	},	
	'addremove' => function () {
		extract($this->gets(['count','model','order_id']), EXTR_REFS);
		if (!$count) $count = false;
		$r = Cart::addModel($order_id, $model, $count);
		if (!$r) return $this->fail('CR015', 'a'.__LINE__);
		if ($count) return $this->ret('CR029', 'a'.__LINE__);
	},	
	'cart' => function () {
		extract($this->gets(['ans','user','meta', 'lang']), EXTR_REFS);

		$statuses = ''; //Все статусы
		$start = 0;
		$end = time();
		if (!$user) return $this->err('noorders', 'a' . __LINE__);

		$list = Cart::getOrders($user, $statuses, $start, $end);

		if (!$list) return $this->err('CR006', 'a' . __LINE__);
		
		foreach ($list as $k => $order) {
			$list[$k]['active'] = Cart::isActive($order, $user);
		}

		$ans['list'] = $list;
		$ans['meta'] = Cart::getJsMeta($meta, $lang);
	}, 	
	'orders' => function () {
		extract($this->gets(['ans','user','meta', 'lang', 'statuses','start']), EXTR_REFS);
		$ans['statuses'] = $statuses;
		$end = strtotime('first day of next month 0:0', $start);
		$ans['start'] = $start;
		$ans['Y'] = date('Y', $start);
		$ans['F'] = Cart::lang($lang, date('F', $start));
		$ans['startstr'] = date('d.m.Y H:i:s', $start);		
		$list = Cart::getOrders($user, $statuses, $start, $end);
		if (!$list) return $this->err('CR006', 'a' . __LINE__);
		$total = 0;
		foreach ($list as $k => $order) {
			/*
				Если в заказе не мой email, то изменения города в шапке на заказ не повлияют, так как не будут менять город у пользователя по email. При freeze нужно фиксировать город.
			*/
			$list[$k]['city'] = Cart::getCity($order['city_id'], $order['email'], $order['order_id'], $lang);
			$total += $order['total'];
		}
		$ans['list'] = $list;
		$ans['total'] = $total;
		$ans['meta'] = Cart::getJsMeta($meta, $lang);
	},	
	'years' => function () {
		extract($this->gets(['ans']), EXTR_REFS);
		$years = Cart::getYears();
		$ans['years'] = $years;
	},	
	'getmeta' => function () {
		extract($this->gets(['ans', 'meta', 'lang']), EXTR_REFS);
		$ans['meta'] = Cart::getJsMeta($meta, $lang);
	},	
	'check' => function () {
		extract($this->gets(['place', 'order', 'order_id', 'lang']), EXTR_REFS);
		
		$this->handler('create_order_user');
		if (!Cart::setStatus($order_id, 'check')) return $this->fail('CR018', 'a' . __LINE__);
		//$ouser = $order['user'];
		$ouser['order'] = Cart::getById($order_id);
		
		if ($place == 'orders') {
			Cart::mailtoadmin($ouser, $lang, 'AdmOrderToCheck');
		}
		Cart::mail($ouser, $lang, 'orderToCheck');
		

		//После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
		$r = Cart::resetActive($order);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);

		$worder = Cart::getWaitOrder($ouser);
		if ($worder) {
			$r = Cart::setActive($worder['order_id'], $ouser['user_id']);
			if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		}

		return $this->ret('CR025', 'a' . __LINE__);
	}, 
	'settransport' => function () {
		extract($this->gets(['transport', 'order_id']), EXTR_REFS);
		//if (!$transport) return $this->fail('transport', 'a' . __LINE__);
		$r = Cart::setTransport($order_id, $transport);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}, 
	'paykeeper' => function () {
		extract($this->gets(['order', 'order_id']), EXTR_REFS);
		$this->handler('create_order_user');
		if (!Cart::setStatus($order_id, 'pay')) return $this->fail('CR018', 'a' . __LINE__);
		//После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
		$r = Cart::resetActive($order);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		return $this->ret('pay3', 'a' . __LINE__);
	}, 
	'tocheck' => function () {
		extract($this->gets(['order','order_id']), EXTR_REFS);
		$email = $order['email'];
		$ouser = User::getByEmail($email);
		if (!Cart::setStatus($order_id, 'check', 'noedit')) return $this->fail('CR018', 'a' . __LINE__);
		return $this->ret('CR025s', 'a' . __LINE__);
	}, 
	'setcallback' => function () {
		extract($this->gets(['order_id','callback']), EXTR_REFS);
		$r = Cart::setCallback($order_id, $callback);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}, 
	'complete' => function () {
		extract($this->gets(['order_id','order']), EXTR_REFS);
		if (!Cart::setStatus($order_id, 'complete')) return $this->fail('CR018', 'a' . __LINE__);
		$r = Cart::resetActive($order);//После того как заказ отправляется на проверку, он у всех перестаёт быть активным.
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		return $this->ret('CR040', 'a' . __LINE__);

	}, 
	'setcommentmanager' => function () {
		extract($this->gets(['commentmanager','order']), EXTR_REFS);
		$r = Cart::setCommentManager($order, $commentmanager);
		return $r ? $this->ret('saved','a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'email' => function () {
		extract($this->gets(['commentmanager','order', 'lang']), EXTR_REFS);
		$order['commentmanager'] = $commentmanager;
		$r = Cart::setCommentManager($order, $commentmanager);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		$ouser = User::getByEmail($order['email']);
		$ouser['order'] = $order;
		$r = Cart::mail($ouser, $lang, 'email');
		if (!$r) return $this->fail('CR018.a7');
		Cart::setEmailDate($order);
		return $this->ret('CR055', 'a' . __LINE__);
	}, 
	'wait' => function () {
		extract($this->gets(['order_id','order']), EXTR_REFS);
		if (!Cart::setStatus($order_id, 'wait')) return $this->fail('CR018', 'a' . __LINE__);
		$fuser = User::getByEmail($order['email']);
		if (!$fuser) return $this->fail('CR018', 'a' . __LINE__);
		Cart::setActive($order['order_id'], $fuser['user_id']);
		if ($fuser != $user && $place == 'orders') Cart::setActive($order['order_id'], $user['user_id']);

		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		return $this->ret('CR030', 'a' . __LINE__);
	}, 
	'delete' => function () {
		extract($this->gets(['order']), EXTR_REFS);
		$r = Cart::delete($order);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		return $this->ret('CR027', 'a' . __LINE__);
	}, 
	'remove' => function () {
		extract($this->gets(['position_ids', 'user']), EXTR_REFS);
		$r = Cart::removePos($position_ids, $user);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		if (sizeof($position_ids) > 1) {
			return $this->ret('CR057', 'a' . __LINE__);
		} else {
			return $this->ret('CR034', 'a' . __LINE__);
		}
	}, 
	'clear' => function () {
		extract($this->gets(['order']), EXTR_REFS);
		if (!Cart::clear($order)) return $this->fail('CR018', 'a' . __LINE__);
		return $this->ret('CR037', 'a' . __LINE__);
	}, 
	'add' => function () {
		extract($this->gets(['order_id', 'position_id', 'count']), EXTR_REFS);
		$r = Cart::add($order_id, $position_id, $count);
		if (!$r) return $this->fail('CR015', 'a' . __LINE__);
		return $this->ret('CR029', 'a' . __LINE__);
	}, 
	'refreezeall' => function () {
		extract($this->gets(['user']), EXTR_REFS);
		$orders = Db::colAll('SELECT order_id from cart_orders where freeze = 1');
		foreach ($orders as $order_id) {
			Cart::freeze($order_id);
		}
		return $this->ret('Выполнена повторная заморозка');
	}, 
	'setlang' => function () {
		extract($this->gets(['order_id', 'lang']), EXTR_REFS);
		//Вызывается для активного заказа при изменении языка на сайте
		$r = Cart::setLang($order_id, $lang);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}, 'setcoupon' => function () {
		extract($this->gets(['order_id', 'coupon']), EXTR_REFS);
		$coupondata = Load::loadJSON('-cart/coupon?name=' . $coupon);
		$r = Cart::setCoupon($order_id, $coupon, $coupondata);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setcity' => function () {
		//При изменении города пересчитывается корзина. Стоимость доставки будет другой.
		extract($this->gets(['order', 'city_id']), EXTR_REFS);
		$r = Cart::setCity($order, $city_id);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setcomment' => function () {
		extract($this->gets(['order_id', 'comment']), EXTR_REFS);
		$r = Db::exec('UPDATE cart_orders
			SET comment = :comment, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':comment' => $comment
		]) !== false;
		return $r ? $this->ret('saved.a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setzip' => function () {
		extract($this->gets(['order_id', 'zip']), EXTR_REFS);
		$zip = (int) $zip;
		if ($zip && strlen($zip) != 6) return $this->err('zip', 'a' . __LINE__);
		$r = Db::exec('UPDATE cart_orders
			SET zip = :zip, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':zip' => $zip
		]) !== false;
		return $r ? $this->ret('saved', 'a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setaddress' => function () {
		extract($this->gets(['order_id', 'address']), EXTR_REFS);
		$err = strlen($address) < 6 || strlen($address) > 200;
		if ($err) $address = '';
		$r = Db::exec('UPDATE cart_orders
			SET address = :address, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':address' => $address
		]) !== false;
		Db::commit();
		if ($err) return $this->err('address', 'a' . __LINE__);
		return $r ? $this->ret('saved', 'a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setname' => function () {
		extract($this->gets(['order_id', 'name']), EXTR_REFS);
		$err = (!$name || strlen($name) < 3 || strlen($name) > 200);
		if ($err) $name = '';
		$r = Db::exec('UPDATE cart_orders
			SET name = :name, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':name' => $name
		]) !== false;
		Db::commit();
		if ($err) return $this->err('CR026', 'a' . __LINE__);
		return $r ? $this->ret('saved', 'a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setphone' => function () {
		extract($this->gets(['order_id', 'phone']), EXTR_REFS);
		$err = !$phone || strlen($phone) < 3 || strlen($phone) > 30;
		if ($err) $phone = '';
		$r = Db::exec('UPDATE cart_orders
			SET phone = :phone, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':phone' => $phone
		]) !== false;
		Db::commit();
		if ($err) return $this->err('5', 'a' . __LINE__);
		return $r ? $this->ret('saved', 'a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setemail' => function () {
		extract($this->gets(['order_id', 'email']), EXTR_REFS);
		$err = !$email;
		$r = Db::exec('UPDATE cart_orders
			SET email = :email, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':email' => $email
		]) !== false;
		Db::commit();
		if ($err) return $this->err('CR005', 'a' . __LINE__);
		return $r ? $this->ret('saved', 'a'.__LINE__) : $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setcdek' => function () {
		extract($this->gets(['order_id', 'city_id', 'pvz', 'transport']), EXTR_REFS);
		$order = Db::fetch('SELECT pvz FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if (!$pvz) $pvz = $order['pvz'];
		$r = Db::exec('UPDATE cart_orders
			SET pvz = :pvz, transport = :transport, city_id = :city_id, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':city_id' => $city_id,
			':transport' => $transport,
			':pvz' => $pvz
		]) !== false;
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
		Cart::recalc($order['order_id']);
	}, 
	'setpvz' => function () {
		extract($this->gets(['order_id', 'pvz']), EXTR_REFS);
		if (!$pvz) return $this->fail('pvz', 'a' . __LINE__);
		$r = Db::exec('UPDATE cart_orders
			SET pvz = :pvz, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':pvz' => $pvz
		]) !== false;
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}, 
	'setpay' => function () {
		extract($this->gets(['order_id', 'pay']), EXTR_REFS);
		$r = Cart::setPay($order_id, $pay);
		if (!$r) return $this->fail('CR018', 'a' . __LINE__);
	}
];

