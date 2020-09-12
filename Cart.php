<?php

namespace infrajs\cart;

use infrajs\cart\Cart;
use akiyatkin\city\City;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\access\Access;
use infrajs\session\Session;
use infrajs\once\Once;
use infrajs\mem\Mem;
use akiyatkin\showcase\Showcase;
use infrajs\load\Load;
use infrajs\template\Template;
use infrajs\each\Each;
use infrajs\mail\Mail;
use infrajs\config\Config;
use infrajs\path\Path;
use infrajs\event\Event;
use infrajs\excel\Xlsx;
use infrajs\each\Fix;
use infrajs\user\User;
use infrajs\view\View;
use infrajs\lang\Lang;
use infrajs\db\Db;
use infrajs\lang\LangAns;
use infrajs\cache\CacheOnce;
use infrajs\user\UserMail;

class Cart
{
	public static $conf = [];
	public static $name = 'cart';
	use CacheOnce;
	use LangAns;
	use UserMail;
	public static function mailbefore(&$data)
	{
	}
	public static function mailafter($data, $r)
	{
	}
	/*
	public static function mail($to, $email, $mailroot, $data = array())
	{
		if (!$email) $email = 'noreplay@' . $_SERVER['HTTP_HOST'];
		if (!$mailroot) return; //Когда не указаний в конфиге... ничего такого...
		$rules = Load::loadJSON('-cart/rules.json');

		$data['host'] = View::getHost();
		$data['link'] = Session::getLink($email);
		$data['email'] = $email;
		$data['user'] = Session::getUser($email);
		$data['time'] = time();
		$data["site"] = $data['host'];

		$subject = Template::parse(array($rules['mails'][$mailroot]), $data);
		$body = Template::parse('-cart/cart.mail.tpl', $data, $mailroot);

		//Mail::toSupport($subject.' - копия для поддержки', $email, $body);

		if ($to == 'user') {
			return Mail::html($subject, $body, true, $email);  //from, to
			//return Mail::fromAdmin($subject, $email, $body);
		}
		if ($to == 'manager') {
			return Mail::html($subject, $body, $email, true); //from, to
			//return Mail::toAdmin($subject,$email,$body);
		}
	}*/
	public static function createNick()
	{
		$today = (int) ((date('m') + 10) . (date('j') + 10));
		$last_day = Mem::get('cart_last_day');
		$sym = Cart::$conf['hostnum'];
		if ($last_day == $today) {
			$num = Mem::get('cart_last_num');
			if (!$num) $num = 0;
			$num = $num + 1;
		} else {
			$num = 0;
		}
		Mem::set('cart_last_day', $today);
		Mem::set('cart_last_num', $num);

		if ($num < 100) {
			$today = (int) ($today . '00');
			$nick = $sym . ($today + $num);
		} else {
			$nick = $sym . $today . $num;
		}
		return $nick;
	}

	// public static function getAllByEmail($email)
	// {
	// 	return static::once('getAllByEmail', $email, function ($email) {
	// 		$sql = 'SELECT uo.order_id
	// 			FROM cart_userorders uo
	// 			LEFT JOIN users u ON u.email = ? and uo.user_id = u.user_id
	// 		';
	// 		$list = Db::colAll($sql, [$email]);
	// 		return $list;
	// 	});
	// }
	public static function getOrders($fuser, $status, $wait, $start, $end)
	{
		return static::once('getOrders', [$fuser, $status, $wait, $start, $end], function ($fuser, $status, $wait, $start, $end) {
			$fields = 'o.order_nick, o.order_id, o.status, o.sum, o.name, o.email, o.coupon, o.paid';
			$fields = 'o.order_id';
			$param = [];
			$param[":start"] = $start;
			$param[":end"] = $end;
			if ($fuser) {
				$param[':user_id'] = $fuser['user_id'];
				$sql = "SELECT DISTINCT $fields
					FROM cart_orders o
					RIGHT JOIN cart_userorders ou on (ou.user_id = :user_id and ou.order_id = o.order_id)
					WHERE datecreate >= FROM_UNIXTIME(:start) and datecreate < FROM_UNIXTIME(:end)
				";
			} else {
				if ($status) {
					$param[':status'] = $status;
					if ($fuser) {
						$param[':user_id'] = $fuser['user_id'];
						$sql = "SELECT DISTINCT $fields
							FROM cart_orders o
							RIGHT JOIN cart_userorders ou on (ou.user_id = :user_id and ou.order_id = o.order_id)
							WHERE datecreate >= FROM_UNIXTIME(:start) and datecreate < FROM_UNIXTIME(:end)
							and o.status = :status
						";
					} else {
						$sql = "SELECT DISTINCT $fields
							FROM cart_orders o
							WHERE datecreate >= FROM_UNIXTIME(:start) and datecreate < FROM_UNIXTIME(:end)
							and o.status = :status
						";
					}
				} else {
					if ($wait) {
						$sql = "SELECT DISTINCT $fields
							FROM cart_orders o
							WHERE datecreate >= FROM_UNIXTIME(:start) and datecreate < FROM_UNIXTIME(:end)
						";
					} else {
						$sql = "SELECT DISTINCT $fields
							FROM cart_orders o
							WHERE datecreate >= FROM_UNIXTIME(:start) and datecreate < FROM_UNIXTIME(:end)
							AND o.status != 'wait' AND o.status != ''
						";
					}
				}
			}
			$sql .= 'ORDER BY o.dateedit DESC';
			$list = Db::colAll($sql, $param);
			foreach ($list as $k => $order_id) {
				$list[$k] = Cart::getById($order_id);
			}
			return $list;
		});
	}
	public static function isActive($order, $user)
	{
		if (!$user) return false;
		return (int) Db::col('SELECT active FROM cart_userorders where user_id = :user_id and order_id = :order_id', [
			'order_id' => $order['order_id'],
			'user_id' => $user['user_id']
		]);
	}
	public static function getJsMetaRule($meta, $status, $lang)
	{
		$orig = $meta['rules'][$status];
		$new = [];
		$new['title'] = Cart::code($lang, $orig['title']);
		$new['caption'] = Cart::code($lang, $orig['caption']);
		$new['short'] = Cart::code($lang, $orig['short']);
		if (!empty($orig['shortactive'])) $new['shortactive'] = Cart::code($lang, $orig['shortactive']);

		//$new['heading'] = Cart::code($lang, $orig['heading']);
		$new['actions'] = $orig['actions'];
		foreach (['orders', 'admin'] as $place) {
			foreach ($new['actions'][$place]['buttons'] ?? [] as $act => $cls) {
				$action = Cart::getJsMetaAction($meta, $act, $lang);
				$action['cls'] = $cls;
				$new['actions'][$place]['buttons'][$act] = $action;
			}
			foreach ($new['actions'][$place]['actions'] ?? [] as $i => $act) {
				$action = Cart::getJsMetaAction($meta, $act, $lang);
				unset($new['actions'][$place]['actions'][$i]);
				$new['actions'][$place]['actions'][$act] = $action;
			}
		}

		return $new;
	}
	public static function getJsMetaAction($meta, $act, $lang)
	{
		if (empty($meta['actions'][$act]['title'])) return false;
		$orig = $meta['actions'][$act];
		$new = [];
		$new['title'] = Cart::code($lang, $orig['title']);
		return $new;
	}
	public static function getJsMeta($meta, $lang = 'ru', $status = false)
	{
		$jsmeta = [];
		$jsmeta['rules'] = [];
		foreach ($meta['rules'] as $status => $orig) {
			$new = Cart::getJsMetaRule($meta, $status, $lang);
			$jsmeta['rules'][$status] = $new;
		}

		$jsmeta['actions'] = [];
		foreach ($meta['actions'] as $act => $orig) {
			$new = Cart::getJsMetaAction($meta, $act, $lang);
			if ($new) $jsmeta['actions'][$act] = $new;
		}


		return $jsmeta;
	}
	public static function getYears($lang = 'ru')
	{
		$sql = 'SELECT UNIX_TIMESTAMP(min(dateedit)) as start FROM cart_orders';
		$end = time();
		$start = Db::col($sql) ?? $end + 1;
		$start -= 60 * 60 * 24 * 30 * 20;
		$list = [];


		$runyear = (int) date('Y', $start);
		$runmonth = (int) date('m', $start);
		$next = strtotime('1.' . $runmonth . '.' . $runyear);
		if (empty($list[$runyear])) $list[$runyear] = [];

		$list[$runyear][] = Cart::getYearsOpt($lang, $next);

		do {
			$runmonth++;
			if ($runmonth == 13) {
				$runyear++;
				$runmonth = 1;
			}
			$next = strtotime('1.' . $runmonth . '.' . $runyear);
			if ($next > $end) break;
			if (empty($list[$runyear])) $list[$runyear] = [];
			$list[$runyear][] = Cart::getYearsOpt($lang, $next);
		} while (true);
		return $list;
	}
	private static function getYearsOpt($lang, $next)
	{
		return [
			"start" => $next,
			"end" => strtotime('+1 month', $next),
			"Y" => (int) date("Y", $next),
			"m" => (int) date('m', $next),
			"F" => Cart::lang($lang, date('F', $next))
		];
	}
	public static function create($user)
	{
		$order_nick = Cart::createNick();
		$sql = 'INSERT INTO cart_orders (datecreate, datewait, dateedit, order_nick, sum) VALUES(now(),now(),now(),?, 0)';
		$order_id = Db::lastId($sql, [$order_nick]);
		if (!$order_id) return false;
		$sql = 'INSERT INTO cart_userorders (user_id, order_id, active) VALUES(?,?,1)';
		Db::lastId($sql, [$user['user_id'], $order_id]);
		return Cart::getById($order_id);
	}
	public static function getActiveOrder($user)
	{
		return static::once('getActiveOrder', $user['user_id'], function ($user_id) {
			$sql = 'SELECT uo.order_id
				FROM cart_userorders uo
				WHERE uo.user_id = ? and uo.active = 1
			';
			$order_id = Db::col($sql, [$user_id]);
			if (!$order_id) return false;
			return Cart::getById($order_id);
		});
	}
	public static function getActiveOrderId($user_id)
	{
		return static::once('getActiveOrderId', $user_id, function ($user_id) {
			$sql = 'SELECT uo.order_id FROM cart_userorders uo WHERE uo.user_id = :user_id and uo.active = 1';
			$order_id = Db::col($sql, [
				':user_id' => $user_id
			]);
			return $order_id;
		});
	}
	public static function getWaitOrder($user)
	{
		return static::once('getWaitOrder', $user['user_id'], function ($user_id) {
			$sql = 'SELECT o.order_id
				FROM cart_userorders uo, cart_orders o
				WHERE uo.user_id = :user_id and o.order_id = uo.order_id and o.status = :status
			';
			$order_id = Db::col($sql, [':user_id' => $user_id, ':status' => 'wait']);
			if (!$order_id) return false;
			return Cart::getById($order_id);
		});
	}
	public static function uniqkey($pos)
	{
		return $pos['model_id'] . $pos['item_num'] . $pos['catkit'];
	}
	public static function getModelTitle($model)
	{
		return $model['Наименование'];
	}
	public static function add(&$order, $model, $count = false)
	{
		// $prodart = Cart::uniqkey($model);
		// foreach ($order['basket'] as $i => $p) {
		// 	//$p = Cart::getPosById($p);
		// 	$pa = Cart::uniqkey($p);
		// 	if ($prodart == $pa) {
		// 		unset($order['basket'][$i]);
		// 		$prodart = $p;
		// 		break;
		// 	}
		// }
		//$model = Cart::getFromShowcase($pos);


		$cost = $model['Цена'];




		$sql = 'INSERT IGNORE INTO cart_basket (
			order_id, basket_title, model_id, item_num, catkit, count, cost, dateadd, dateedit
		) VALUES (
			:order_id, :basket_title, :model_id, :item_num,	:catkit, :count, :cost, now(), now()
		)';
		$title = Cart::getModelTitle($model);
		$position_id = Db::lastId($sql, [
			':order_id' => $order['order_id'],
			':model_id' => $model['model_id'],
			':item_num' => $model['item_num'],
			':catkit' => !empty($model['kit']) ? $model['catkit'] : '',

			':basket_title' => $title,
			':cost' => $cost,
			':count' => $count
		]);

		if (!$position_id) {
			//update
			$position_id = Db::col('SELECT position_id FROM cart_basket 
				WHERE order_id = :order_id and catkit = :catkit and item_num = :item_num and model_id = :model_id', [
				':order_id' => $order['order_id'],
				':model_id' => $model['model_id'],
				':item_num' => $model['item_num'],
				':catkit' => !empty($model['kit']) ? $model['catkit'] : ''
			]);
			if (!$position_id) return false;

			$sql = 'UPDATE cart_basket
				SET count = :count, basket_title = :basket_title, cost = :cost, dateedit = now()
				WHERE position_id = :position_id
			';
			$r = Db::exec($sql, [
				':position_id' => $position_id,
				':basket_title' => $title,
				':cost' => $cost,
				':count' => $count
			]) !== false;

			if (!$r) return false;
		}
		if ($count === false) {
			$sql = 'DELETE FROM cart_basket WHERE position_id = :position_id';
			$r = Db::exec($sql, [
				':position_id' => $position_id
			]) !== false;
			return $r;
		}
		if ($order['freeze']) {
			if (!Cart::setToJson($position_id, $model)) return false;
		}


		$r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function couponCheck($model, $coupondata)
	{
		if (!$coupondata || !$coupondata['result']) return false;
		$r = true;
		foreach ($coupondata['rows'] as $row) {
			$rr = true;
			if (isset($row['Производители'])) {
				if (!in_array($model['producer_nick'], $row['Производители'])) {
					$rr = false;
					continue;
				}
			}
			if (isset($row['Группы'])) {
				$rg = false;
				foreach ($model['path'] as $g) {
					if (in_array($g, $row['Группы'])) {
						$rg = true;
						break;
					}
				}
				if (!$rg) {
					$rr = false;
					continue;
				}
			}
			if ($rr) break;
		}
		if ($rr) {
			$res = $row; //Когда пройена предварительная проверка
		} else {
			$res = false;
		}
		if ($res) {
			$r = Event::fire('Cart.coupon', $model);
			if (!$r) $res = false;
		}
		return $res;
	}
	// public static function getCost($order, $model)
	// {
	// 	$cost = $model['Цена'];
	// 	if ($order['coupondata']) {
	// 		$coupondata = $order['coupondata'];
	// 		//$coupon = Load::loadJSON('-cart/coupon?name=' . $order['coupon']);
	// 		$res = Cart::couponCheck($model, $coupondata);
	// 		if ($res) { //Действует
	// 			$discount = $coupondata['Скидка'];
	// 			$cost = $cost * (1 - $discount);
	// 		}
	// 	}
	// 	$cost = round($cost, 2);
	// 	return $cost;
	// }
	
	// public static function edit($order, $data)
	// {
	// 	static::$once = [];
	// 	$sql = 'UPDATE cart_orders
	// 		SET 
	// 		phone = :phone, 
	// 		email = :email, 
	// 		comment = :comment,
	// 		address = :address,
	// 		zip = :zip,
	// 		name = :name, 
	// 		dateedit = now()
	// 		WHERE order_id = :order_id
	// 	';
	// 	$data[':order_id'] = $order['order_id'];
	// 	return Db::exec($sql, $data) !== false;
	// }
	public static function resetActive($order)
	{
		//Найти всех пользователей и что-то сделать у них активным если есть
		$sql = 'UPDATE cart_userorders
			SET active = 0
			WHERE order_id = :order_id
		';
		return Db::exec($sql, [
			':order_id' => $order['order_id']
		]) !== false;
	}
	public static function resetUserActive($user_id)
	{
		$sql = 'UPDATE cart_userorders
			SET active = 0
			WHERE user_id = :user_id
		';
		return Db::exec($sql, [
			':user_id' => $user_id
		]) !== false;
	}
	public static function setLang($order, $lang)
	{
		$sql = 'UPDATE cart_orders
			SET lang = :lang
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':lang' => $lang
		]) !== false;
		return $r;
	}
	public static function setTransport($order, $transport)
	{
		$sql = 'UPDATE cart_orders
			SET transport = :transport, dateedit = now()
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':transport' => $transport
		]) !== false;
		if (!$r) return false;
		$r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function setCommentManager($order, $commentmanager)
	{
		$sql = 'UPDATE cart_orders
			SET commentmanager = :commentmanager
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':commentmanager' => $commentmanager
		]) !== false;
		return $r;
	}
	public static function setPay($order, $pay)
	{
		$sql = 'UPDATE cart_orders
			SET pay = :pay, dateedit = now()
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':pay' => $pay
		]) !== false;
		return $r;
	}
	public static function setCoupon($order, $coupon, $coupondata)
	{
		//При изменении позиции в каталоге. Позиция не пересчитыватся. 
		//Но пересчитывается перед freeze.
		//Купон фризится в момент установки и применяется в поле discount у каждой позиции
		$sql = 'UPDATE cart_orders
			SET coupon = :coupon, coupondata = :coupondata, dateedit = now()
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':coupon' => $coupon,
			':coupondata' => json_encode($coupondata, JSON_UNESCAPED_UNICODE)
		]) !== false;
		if (!$r) return false;
		$r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function setCallback($order, $callback)
	{
		$sql = 'UPDATE cart_orders
			SET callback = :callback, dateedit = now()
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':callback' => $callback
		]) !== false;
		return $r;
	}
	public static function setCity($order, $city_id)
	{
		$sql = 'UPDATE cart_orders
			SET city_id = :city_id, dateedit = now()
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':city_id' => $city_id
		]) !== false;
		if (!$r) return false;
		$r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function setActive($order_id, $user_id)
	{
		$r = Cart::resetUserActive($user['user_id']);
		if (!$r) return $r;
		$sql = 'UPDATE cart_userorders
			SET active = 1
			WHERE order_id = :order_id
			AND user_id = :user_id
		';
		return Db::exec($sql, [
			':order_id' => $order_id,
			':user_id' => $user_id
		]) !== false;
	}
	public static function clear(&$order)
	{

		$sql = 'DELETE b FROM cart_basket b
			WHERE b.order_id = :order_id 
		';
		if (Db::exec($sql, [
			':order_id' => $order['order_id']
		]) === false) return false;
		$r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function removePos($position_ids)
	{
		$order_ids = Db::colAll('SELECT DISTINCT order_id FROM cart_basket where position_id in (' . implode(',', $position_ids) . ')');
		if (!$order_ids) return true; //Позиции нет
		if (sizeof($order_ids) > 1) return false;
		$order_id = $order_ids[0];

		$sql = 'DELETE b FROM cart_basket b
			WHERE b.position_id in (' . implode(',', $position_ids) . ')
		';
		if (Db::exec($sql) === false) return false;

		$r = Cart::recalc($order_id);
		return $r;
	}
	public static function saveTransportCost($order, $type, $cost, $min, $max)
	{
		if (!isset($order['transport'][$type])) {
			$sql = 'INSERT INTO cart_transports (order_id, type, cost, min, max) VALUES(:order_id, :type, :cost, :min, :max)';
		} else {
			$sql = 'UPDATE cart_transports SET cost = :cost, min = :min, max = :max
			WHERE order_id = :order_id and type = :type';
		}
		$r = Db::exec($sql, [
			':order_id' => $order['order_id'],
			':type' => $type,
			':cost' => $cost,
			':min' => $min,
			':max' => $max
		]) === false;
		return $r;
		/*
		$sql = 'INSERT INTO cart_basket (
				order_id, basket_title, model_id, item_num, catkit, count, hash, cost, sum, dateadd, dateedit
			) VALUES (
				:order_id, :basket_title, :model_id, :item_num,	:catkit, :count, :hash,	:cost, :sum, now(), now()
			)';
			$position_id = Db::lastId($sql, [
				':order_id' => $order['order_id'],
				':basket_title' => $model['Наименование'],
				':model_id' => $model['model_id'],
				':item_num' => $model['item_num'],
				':catkit' => $model['catkit'],
				':hash' => $hash,
				':cost' => $cost,
				':sum' => $sum,
				':count' => $count
			]);
			if (!$position_id) return false;

			if ($order['freeze']) {
				if (!Cart::setToJson($position_id, $model)) return false;
			}
		} else { //update
			$position_id = $prodart['position_id'];

			$sql = 'UPDATE cart_basket
				SET count = :count, hash = :hash, cost = :cost, sum = :sum, dateedit = now()
				WHERE position_id = :position_id
			';
			*/
	}
	public static function recalc($order_id)
	{
		//Меняются 
		//sum, discount, cost, transports
		unset(static::$once['getById'][$order_id]); //Без кэша
		//Считаем сумму $order['basket'] + $model * $count
		$order = Cart::getById($order_id);
		if ($order['paid']) return false; //Оплаченный заказ нельзя пересчитывать

		foreach ($order['basket'] as $k => $pos) {
			$model = $pos['model'];


			$discount = null;
			if ($order['coupondata']) {
				$coupondata = $order['coupondata'];
				$res = Cart::couponCheck($model, $coupondata);
				$cost = $model['Цена'];
				if ($res) { //Действует
					$discount = $coupondata['Скидка'];
					$cost = $cost * (1 - $discount);
				}
			} else {
				$cost = $model['Цена'];
			}
			$cost = round($cost, 2);



			$sum = $cost * $pos['count'];

			$order['basket'][$k]['sum'] = $sum;

			$sql = 'UPDATE cart_basket
				SET sum = :sum, cost = :cost, discount = :discount
				WHERE position_id = :position_id
			';
			if (Db::exec($sql, [
				':position_id' => $pos['position_id'],
				':cost' => $cost,
				':discount' => $discount ? $discount * 100 : null,
				':sum' => $sum
			]) === false) return false;
		}

		$sum = 0;
		foreach ($order['basket'] as $p) {
			$sum += $p['sum'];
		}
		$total = $sum;
		//order: city_id, basket - размеры, вес, 
		$transports = Cart::$conf['transports'];

		$type = 'city';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 13, 1, 2);
		if ($order['transport'] == $type) $total += 13;

		$type = 'self';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 0, 1, 2);
		if ($order['transport'] == $type) $total += 0;

		$type = 'cdek_pvz';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 123, 1, 2);
		if ($order['transport'] == $type) $total += 123;

		$type = 'cdek_courier';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 123, 3, 4);
		if ($order['transport'] == $type) $total += 123;

		$type = 'pochta_simple';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 123, 2, 5);
		if ($order['transport'] == $type) $total += 123;

		$type = 'pochta_1';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 123, 1, 2);
		if ($order['transport'] == $type) $total += 123;

		$type = 'pochta_courier';
		if (in_array($type, $transports)) Cart::saveTransportCost($order, $type, 123, 1, 1);
		if ($order['transport'] == $type) $total += 123;

		//Доставка
		//Купон применяется к позиции. Результат с купоном хранится в описании позиции в корзине, так как его нужно замораживать и не пересчитывать для freeze
		//У позиции есть ценаsum - после скидки и cost*count до скидки.

		$sql = 'UPDATE cart_orders
			SET sum = :sum
			WHERE order_id = :order_id
		';
		if (Db::exec($sql, [
			':order_id' => $order['order_id'],
			':sum' => $sum
		]) === false) return false;

		return true;
	}

	public static function delete($order)
	{
		$sql = 'DELETE o, uo, b 
			FROM cart_orders o
			LEFT JOIN cart_userorders uo on o.order_id = uo.order_id
			LEFT JOIN cart_basket b on b.order_id = o.order_id
			WHERE o.order_id = :order_id 
		';
		if (Db::exec($sql, [
			':order_id' => $order['order_id']
		]) === false) return false;
		return true;
	}
	public static function setStatus($order, $status)
	{
		$sql = 'UPDATE cart_orders
			SET status = :status, dateedit = now(), date' . $status . ' = now()
			WHERE order_id = :order_id
		';
		if (Db::exec($sql, [
			':order_id' => $order['order_id'],
			':status' => $status
		]) === false) return false;
		return true;
	}
	public static function getByNick($order_nick)
	{
		$order_id = static::once('getByNick', $order_nick, function ($order_nick) {
			$sql = 'SELECT order_id
				FROM cart_orders where order_nick = ?';
			return Db::col($sql, [$order_nick]);
		});
		if (!$order_id) return false;
		return Cart::getById($order_id);
	}
	public static function setEmailDate($order)
	{
		$sql = 'UPDATE cart_orders
			SET dateemail = now()
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id']
		]) !== false;
		return $r;
	}

	public static function getById($order_id)
	{
		return static::once('getById', $order_id, function ($order_id) {
			$sql = 'SELECT 
					order_id, 
					status,
					name,
					phone,
					pay,
					callback,
					transport,
					city_id,
					freeze,
					sum,
					coupon, coupondata,
					paid,
					order_nick, 
					email, 
					address,
					zip,
					comment,
					commentmanager,
					UNIX_TIMESTAMP(datecreate) as datecreate,
					UNIX_TIMESTAMP(datewait) as datewait,
					UNIX_TIMESTAMP(dateedit) as dateedit,
					UNIX_TIMESTAMP(datecheck) as datecheck,
					UNIX_TIMESTAMP(datecomplete) as datecomplete,
					UNIX_TIMESTAMP(datepay) as datepay,
					UNIX_TIMESTAMP(datepaid) as datepaid,
					UNIX_TIMESTAMP(dateemail) as dateemail
				FROM cart_orders where order_id = ?
			';
			$order = Db::fetch($sql, [$order_id]);
			if (!$order) return false;
			$sql = 'SELECT 
					position_id,
					basket_title, 
					model_id,
					item_num,
					catkit,
					hash,
					cost,
					sum,
					discount,
					count
				FROM cart_basket 
				WHERE order_id = :order_id
				order by dateadd DESC
			';
			$order['basket'] = Db::all($sql, ['order_id' => $order_id]);
			$order['sumclear'] = 0;
			foreach ($order['basket'] as $i => $pos) {
				// echo '<pre>';
				// print_r($pos);
				$order['basket'][$i]['cost'] = (float) $pos['cost'];
				$model = Cart::getFromShowcase($pos);

				$pos['sumclear'] = $model['Цена'] * $pos['count'];
				$order['sumclear'] += $pos['sumclear'];

				
				if ($order['freeze']) {
					$hash = Cart::getHash($model); //Если модели нет, hash будет пустой строкой и будет ме5тка что есть изменение
					$order['basket'][$i]['changed'] = $pos['hash'] !== $hash;
					$model = Cart::getFromJson($pos);
				} else {
					if (!$model) continue; //Модель не заморожена и не найдена в каталоге
					$order['basket'][$i]['changed'] = false;
				}
				$order['basket'][$i]['model'] = $model;

				unset($order['basket'][$i]['hash']);
			}
			//Редактировать заявку может менеджер, и к user мы не можем обращаться. Надо знать email или phone, но у заказа они могут быть не указаны
			//$order['user'] = User::getByEmail($order['email']);
			if ($order['email']) {
				$order['user'] = User::getByEmail($order['email']);
			}
			if (empty($order['user'])){ //Пользователь заказа есть всегда в таблице владельцев
				$user_id = Db::col('SELECT user_id from cart_userorders WHERE order_id = :order_id', [
					':order_id' => $order_id
				]);
				$order['user'] = User::getById($user_id);
			}

			$city_id = $order['city_id'] ? $order['city_id'] : $order['user']['city_id'];
			$order['city'] = City::getById($city_id, $order['user']['lang']);
			$order['city']['zips'] = City::getIndexes($city_id);
			$order['active'] = Cart::isActive($order, $order['user']);

			$sql = 'SELECT cost, min, max, type
				FROM cart_transports 
				WHERE order_id = :order_id
			';

			$order['transports'] = Db::allto($sql, 'type', [
				'order_id' => $order_id
			]);
			if (!$order['transport']) $order['transport'] = 'cdek_pvz';
			$order['sumtrans'] = 0;
			if ($order['transport'] && isset($order['transports'][$order['transport']])) {
				$order['sumtrans'] = $order['transports'][$order['transport']]['cost'];	
			}
			$order['total'] = $order['sumtrans'] + $order['sum'];


			if ($order['coupondata']) $order['coupondata'] = json_decode($order['coupondata'], true);

			return $order;
		});
	}
	public static function getHash($model)
	{
		$hash = md5(json_encode($model, JSON_UNESCAPED_UNICODE));
		return $hash;
	}
	// public static function getModel($order, $pos)
	// {
	// 	if ($order['freeze']) {
	// 		return Cart::getFromJson($pos);
	// 	} else {
	// 		return Cart::getFromShowcase($pos);
	// 	}
	// }
	public static function getFromJson($pos)
	{
		//position_id, model_id, item_num, catkit, freeze, hash
		$sql = 'SELECT json from cart_basket WHERE position_id = :position_id';
		$json = Db::col($sql, [':position_id' => $pos['position_id']]);
		$model = json_decode($json, true);
		return $model;
	}

	public static function setToJson($position_id, $model)
	{
		$json = json_encode($model, JSON_UNESCAPED_UNICODE);
		$hash = Cart::getHash($model);
		$cost = $model['Цена'];
		$title = Cart::getModelTitle($model);
		$sql = 'UPDATE cart_basket
			SET json = :json, cost = :cost, hash = :hash, basket_title = :basket_title
			WHERE position_id = :position_id
		';

		$r = Db::exec($sql, [
			':position_id' => $position_id,
			':json' => $json,
			':cost' => $cost,
			':basket_title' => $title,
			':hash' => $hash
		]) !== false;

		return $r;
	}
	public static function getFromShowcase($pos)
	{
		return Showcase::getModelById($pos['model_id'], $pos['item_num'], $pos['catkit']);
	}
	public static function freeze($order)
	{
		$sql = 'UPDATE cart_orders
			SET freeze = 1
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id']
		]) !== false;
		if (!$r) return $r;


		foreach ($order['basket'] as $pos) {
			$model = Cart::getFromShowcase($pos);
			//Если модели нет в каталоге. надо удалить её из корзины. Такая проверка должна быть раньше.
			if (!Cart::setToJson($pos['position_id'], $model)) return false;

			//position_id, model_id, item_num, catkit, freeze, hash
			//$position_id = $pos['position_id']
		}
		$r = Cart::recalc($order['order_id']); //Установятся актуальные цены
		return $r;
	}
	public static function unfreeze($order)
	{
		$sql = 'UPDATE cart_orders
			SET freeze = 0
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order['order_id']
		]) !== false;
		if (!$r) return $r;

		$sql = 'UPDATE cart_basket
			SET json = null
			WHERE order_id = :order_id
		';

		$r = Db::exec($sql, [
			':order_id' => $order['order_id']
		]) !== false;
		if (!$r) return false;
		$r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function getUsers($order)
	{

		// $sql = 'SELECT user_id
		// 	FROM cart_userorders
		// 	WHERE order_id = :order_id AND active = 1
		// ';{
		// $order['acitve'] = Db::colAll($sql, ['order_id'=>$order_id]);
		$sql = 'SELECT user_id, active
			FROM cart_userorders
			WHERE order_id = :order_id
		';
		$users = Db::all($sql, ['order_id' => $order['order_id']]);
		return $users;
	}


	public static function setOwner($order, $fuser)
	{
		if (Cart::isOwner($order, $fuser)) return true;
		$sql = 'INSERT INTO cart_userorders (user_id, order_id) VALUES(:user_id,:order_id)';
		return Db::exec($sql, [
			':user_id' => $fuser['user_id'],
			':order_id' => $order['order_id']
		]);
	}
	public static function isOwner($order, $user)
	{ //action true совпадёт с любой строчкой
		if (!$user) return false;
		$users = Cart::getUsers($order);
		foreach ($users as $u) {
			if ($u['user_id'] == $user['user_id']) return true;
		}
		//Тут проверяется есть ли необходимое действие в списке действий с заявкой с таким статусом
		return false;
	}
};




























Event::$classes["Cart"] = function ($pos) {
	return $pos["model_id"] . $pos["item_num"] . $pos['catkit'];
};
/*


Event::$classes["Order"] = function ($order) {
	return $order['id'];
};
class Cart2
{
	public static function getPath($id = '')
	{
		if (!$id) return '~auto/.cart/';
		return '~auto/.cart/' . $id . '.json';
	}
	public static function getMyOrders()
	{
		return Once::func(function () {
			$myorders = Session::get('safe.orders', array());

			$list = array();
			for ($i = 0, $l = sizeof($myorders); $i < $l; $i++) {
				$id = $myorders[$i];
				$order = Cart::getGoodOrder($id);
				if (!$order) continue;
				if ($order['status'] == 'active') continue; //WTF?
				$list[] = $order;
			}

			usort($list, function ($a, $b) {
				return $a['time'] < $b['time'];
			});

			return $list;
		});
	}
	public static function getByProdart($prodart)
	{
		$prodart = trim($prodart);
		if (!$prodart) return [];
		$query = explode(" ", $prodart);
		$query = implode("/", $query);
		$data = Load::loadJSON('-showcase/api/pos/' . $query);
		$pos = $data['pos'];
		return $pos;
	}
	public static function getGoodOrder($id = '')
	{
		if (is_array($id)) {
			$order = $id;
			if (empty($order['id'])) {
				$id = null;
			} else {
				$id = $order['id'];
			}
		} else {
			$order = false;
		}
		return Once::func(function & ($id) use (&$order) {

			if (!$order) $order = Cart::loadOrder($id);

			$r = false;
			if (!$order) return $r; //Нет заявки с таким $id
			$order['id'] = $id;
			$order['rule'] = Cart::getRule($order);



			if (empty($order['email'])) $order['email'] = '';
			$order['email'] = trim($order['email']);
			$order['sum'] = 0;
			$order['count'] = 0;
			$num = 0;
			$zerro = false;
			Each::foro($order['basket'], function & (&$pos, $prodart) use (&$order, &$num, &$zerro) {
				$r = null;
				if (!isset($pos['count'])) $pos['count'] = 0;
				$count = $pos['count']; //Сохранили значение из корзины
				if (empty($pos['Цена'])) $pos['Цена'] = 0;
				if ($count < 1) {
					$r = new Fix('del');
					return $r;
				}
				if (empty($order['rule']['freeze'])) {
					$pos = Cart::getByProdart($prodart);
					if (!$pos) {
						$r = new Fix('del');
						return $r;
					}
				} else {
					$p = Cart::getByProdart($prodart);
					if (empty($pos['article_nick'])) { //Такое может быть со старыми заявками... deprcated удалить потом.
						//Значит позиция некорректно заморожена
						$pos = Cart::getByProdart($prodart);
						if (!$pos) {
							$r = new Fix('del');
							return $r;
						}
					} else {
						$hash = Cart::getPosHash($p);
						if ($pos['hash'] != $hash) $pos['change'] = true; //Метка что что-то поменялось в описании позиции.
					}
				}
				if (empty($pos['Цена'])) {
					$zerro = true;
					$pos['Цена'] = 0;
				}

				$pos['num'] = ++$num;
				$pos['count'] = $count;
				$order['count']++;
				$conf = Config::get('cart');

				$pos['sum'] = $pos['Цена'] * $pos['count'];

				$order['sum'] += $pos['sum'];

				return $r;
			});

			if ($zerro)  $order['sum'] = 0;
			$hadpaid = 0; //Сумма уже оплаченных заявок

			//В заявке сохранён email по нему можно получить пользователя и все его заявки
			//email появляется у активной заявки и потом больше не меняется
			$orders = Session::user_get($order['email'], 'safe.orders', array()); //Получить значение сессии какого-то пользователя

			//Если заявка числится у нескольких пользователей, в safe.orders мы будем смотреть по текущей
			//В общем то что заявка у нескольких пользователей пофигу. 
			//Менеджер отталкиваемся пользователя который перевёл заявку из активного статуса, самый первый именно он попадает в order.email это в saveOrder

			Each::forr($orders, function & ($id) use (&$hadpaid, $order) {
				$r = null;
				if ($order['id'] == $id) return $r; //Текущую заявку не считаем
				$order = Cart::loadOrder($id);
				$rules = Load::loadJSON('-cart/rules.json');

				if (empty($order['manage']['paid'])) return $r; //Если статус не считается оплаченым выходим
				if (in_array($order['status'], array('canceled', 'error'))) return $r; //Если статус не считается оплаченым выходим
				if ($order['manage']['bankrefused']) return $r;

				//Хотя оплачена alltotal вместе с доставкой
				//if (!$order['total']) return;//У оплаченой заявки обязательно должно быть total оплаченная, без цены доставки.
				//$order['manage']['paid'] вся оплаченная сумма с заявкой, по факту.
				$hadpaid += $order['manage']['paid'];
				return $r;
			});
			$order['hadpaid'] = $hadpaid;
			//sum цена всех товаров
			//total цена всех товаров с учётом цены указанной менеджером, тобишь со скидкой

			$conf = Config::get('cart');

			//$pos['cost'] = $pos['Цена'];

			Each::foro($order['basket'], function & (&$pos) {
				$r = null;
				if (empty($pos['Цена'])) $pos['Цена'] = 0;
				$pos['cost'] = $pos['Цена'];
				return $r;
			});

			$order['total'] = $order['sum'];

			if (!empty($order['coupon'])) {
				$coupon = Load::loadJSON('-cart/coupon?name=' . $order['coupon']);
				$order['coupon_data'] = $coupon;
				if ($coupon['result']) {
					$order['total'] = 0;
					Each::foro($order['basket'], function & (&$pos, $prodart) use (&$coupon, &$order) {


						$res = Cart::couponCheck($pos, $coupon);
						if ($res) { //Действует
							$pos['coupon'] = $res;
							$discount = $pos['coupon']['Скидка'];
							$pos['coupcost'] = $pos['Цена'] * (1 - $discount);
							$sum = $pos['Цена'] * $pos['count'] * (1 - $discount);
							if ($pos['coupcost'] == $pos['Цена']) {
								unset($pos['coupcost']);
							} else {
								$pos['coupcost'] = round($pos['coupcost'], 2);
							}
							$pos['coupsum'] = round($sum, 2);
						} else { //Не дейстует
							$sum = $pos['Цена'] * $pos['count'];
						}


						$order['total'] += $sum;
						$r = null;
						return $r;
					});
					$order['total'] = round($order['total'], 2);
				}


				//if ($coupon['result']) {
				//$fncost = Template::$scope['~cost'];
			}
			if (!empty($order['manage']['summary'])) {
				$order['manage']['summary'] = preg_replace('/\s/', '', $order['manage']['summary']);
				$order['total'] = $order['manage']['summary'];
			}
			//Стоимость с доставкой
			$order['alltotal'] = $order['total'];
			if (!empty($order['manage']['deliverycost'])) {
				$order['manage']['deliverycost'] = preg_replace('/\s/', '', $order['manage']['deliverycost']);
				$order['alltotal'] += $order['manage']['deliverycost'];
			}

			// if ($order['status'] == 'sbrfpay' 
			// 	&& isset($order['sbrfpay']['orderId']) 
			// 	&& empty(isset($order['sbrfpay']['info'])) ) {
			// 	//Есть информация что выдана ссылка, и нет информации об оплате
			// 	//Такое может быть если человек не переходил по ссылке success
			// }

			Event::fire('Order.calc', $order);
			return $order;
		}, array($id));
	}
	public static function clearActiveSession()
	{
		Session::set('orders.my.basket'); //Очистили заявку
		Session::set('orders.my.id');
		Session::set('orders.my.fixid');
		Session::set('orders.my.copyid');
		Session::set('orders.my.time');
		Session::set('orders.my.comment');
		Session::set('orders.my.manage');
		Session::set('orders.my.sbrfpay');
		Session::set('orders.my.paykeeper');
	}
	public static function couponCheck($coupon, &$pos)
	{
		$r = true;
		foreach ($coupon['rows'] as $row) {
			$rr = true;
			if (isset($row['Производители'])) {
				if (!in_array($pos['producer_nick'], $row['Производители'])) {
					$rr = false;
					continue;
				}
			}
			if (isset($row['Группы'])) {
				$rg = false;
				foreach ($pos['path'] as $g) {
					if (in_array($g, $row['Группы'])) {
						$rg = true;
						break;
					}
				}
				if (!$rg) {
					$rr = false;
					continue;
				}
			}
			if ($rr) break;
		}
		if ($rr) {
			$res = $row; //Когда пройена предварительная проверка
		} else {
			$res = false;
		}
		if ($res) {
			$r = Event::fire('Cart.coupon', $pos);
			if (!$r) $res = false;
		}
		return $res;
	}
	public static function sync($place, $orderid)
	{
		$order = Cart::loadOrder($orderid);
		$rule = Cart::getRule($order);
		if (($place == 'admin' && Session::get('safe.manager')) || !empty($rule['edit'][$place])) { //Place - orders admin wholesale

			$r = Cart::mergeOrder($order, $place);
			//if ($r) 
			Cart::saveOrder($order, $place);
		} else {
			$r = Cart::mergeOrder($order, $place, true);
			//if ($r) 
			Cart::saveOrder($order, $place);
		}
	}
	public static function isMy($id)
	{
		if (!$id) return true;
		$ar = Session::get('safe.orders', array());
		return in_array($id, $ar);
	}
	// public static function canI($id, $action = true)
	// { //action true совпадёт с любой строчкой
	// 	if (!$id) return true;

	// 	//if (Load::isphp()) return true;
	// 	if (Session::get('safe.manager')) return true;
	// 	if (!Cart::isMy($id)) return false;
	// 	$order = Cart::loadOrder($id);
	// 	if ($action === true) return true;
	// 	$rule = Cart::getRule($order);
	// 	return Each::exec($rule['user']['actions'], function & ($a) use ($action) {
	// 		$r = null;
	// 		if ($a['act'] == $action) $r = true;
	// 		return $r;
	// 	});
	// }
	public static function &loadOrder($id = '')
	{
		//Результат этой фукции можно сохранять в файл она не добавляет лишних данных, но оптимизирует имеющиеся
		return Once::func(function & ($id) {
			if ($id) {
				$order = Load::loadJSON(Cart::getPath($id));
				$r = false;
				if (!$order) return $r; //Нет такой заявки с таким id
				//$email=Session::getEmail();


				//У хранящейся Активной заявки есть id, но если мы по id обращаемся значит не нужно применять ту что в сессии user
				//if ($order['status']=='active') {
				//	if ($order['email']==$email) {
				//		return Cart::loadOrder();
				//	}
				//}
				//Применили последний автоsave
				//С какого места вызывали и чью сессию применять

				//Права доступа тут не проверяются
				//Менеджер Отредактировал заявку в admin перешёл в orders увидел тоже самое

				//Если я менеджер сессия применяется всегда.
				//Если не менеджер то только если разрешено в месте orders  
				$order['id'] = $id;
				$rules = Cart::getRule();
				if (empty($rules['rules'][$order['status']])) $order['status'] = $rules['def'];
			} else {
				$order = Session::get('orders.my', array());
				Each::foro($order, function & (&$val, $name) {
					$r = null;
					if (is_string($val)) $val = trim($val);
					return $r;
				});

				$order['status'] = 'active';
			}
			if (empty($order['manage'])) $order['manage'] = array();
			return $order;
		}, array($id));
	}
	public static function getRule($order = false)
	{
		$rules = Load::loadJSON('-cart/rules.json');
		if (!$order) return $rules;

		foreach ($rules as $i => $act) {
			if (!empty($rules[$i]['link'])) $rules[$i]['link'] = Template::parse(array($rules[$i]['link']), $order);
		}
		$rule = $rules['rules'][$order['status']];
		$list = array(&$rule['manager'], &$rule['user']);

		Each::exec($list, function & (&$ar) use ($rules, &$order) {
			$r = null;

			Each::foro($ar['buttons'], function & (&$cls, $act) use ($rules, &$order, &$ar) {
				$r = null;
				// $index=array_search($act, $ar['actions']);
				// if ($index!==false) {
				// 	array_splice($ar['actions'],$index,1);
				// }

				if (!$rules['actions'][$act]) {
					$cls = array(
						'cls' => $cls,
						'act' => $act
					);
				} else {
					$t = $cls;
					$cls = $rules['actions'][$act];
					$cls['act'] = $act;
					$cls['cls'] = $t;
				}
				if (!empty($cls['omit'])) {
					$omit = Template::parse(array($cls['omit']), $order);
					if ($omit) {
						$fix = new Fix('del');
						return $fix;
					}
				}
				return $r;
			});

			if ($ar['buttons']) { //Все кнопки добавим в список
				$buttons = array_keys($ar['buttons']);
				$ar['actions'] = array_merge($ar['actions'], $buttons);

				$ar['actions'] = array_unique($ar['actions']);
				$ar['actions'] = array_values($ar['actions']);
			}

			Each::exec($ar['actions'], function & (&$act) use ($rules, &$order) {


				if (!$rules['actions'][$act]) {
					$cls = array(
						'act' => $act
					);
				} else {
					$cls = $rules['actions'][$act];
					$cls['act'] = $act;
				}

				if (!empty($cls['omit'])) {
					$omit = Template::parse(array($cls['omit']), $order);
					if ($omit) {
						$r = new Fix('del');
						return $r;
					}
				}
				$act = $cls;
				return $r;
			});
			return $r;
		});
		return $rule;
	}



	public static function mergeOrder(&$order, $place, $safe = false)
	{
		if (empty($order['id'])) return;

		if (!$safe) {
			$actualdata = Session::get([$place, $order['id']], array());
			foreach ($actualdata as $name => $val) {
				if (!is_string($val)) continue;
				$actualdata[$name] = mb_substr(trim(strip_tags($val)), 0, 200);
			}
		} else { //Когда нельзя редактировать... если хочется то можно сохранить комент
			$val = Session::get([$place, $order['id'], 'comment'], '');
			$actualdata['comment'] = mb_substr(trim(strip_tags($val)), 0, 20000);
		}
		if (!Session::get('safe.manager') || $place != 'admin') {
			unset($actualdata['manage']); //Только админ на странице admin может менять manage
		}
		if (!$actualdata) return false;


		foreach (['manage', 'basket', 'transport', 'pay'] as $name) {
			if (empty($actualdata[$name])) continue;
			if (empty($order[$name])) continue;
			$actualdata[$name] = array_merge($order[$name], $actualdata[$name]);
		}
		$order = array_merge($order, $actualdata);
		return true;
	}
	public static function catchOrder($order, $email = false)
	{
		$id = $order['id'];
		if (!$email) {
			$myorders = Session::get(['safe', 'orders'], array());
			$myorders[] = $id;
			Session::set(['safe', 'orders'], array_unique($myorders));
		} else {
			$user = Session::getUser($order['email']);
			if (!$user) $user = Session::createUser($order['email']);

			$myorders = Session::user_get($order['email'], 'safe.orders', array());
			$myorders[] = $id;
			Session::user_set($order['email'], ['safe', 'orders'], array_unique($myorders));
		}
	}
	public static function saveOrder(&$order, $place = false)
	{
		if (!empty($order['id'])) $id = $order['id'];
		else $id = false;

		if (!$id) {
			if (!empty($order['fixid'])) {

				$id = $order['fixid']; //Заявка уже есть в списке моих заявок

			} else if ($order['status'] == 'active') {
				//Сохранить активную заявку
				//Активная заявка и нет fixid не сохраняем в файл
				Session::set('orders.my', $order); //Исключение, данные заявки
				return;
			} else {
				$today = (int) ((date('m') + 10) . (date('j') + 10));
				$last_day = Mem::get('cart_last_day');
				$sym = Cart::$conf['hostnum'];
				if ($last_day == $today) {
					$num = Mem::get('cart_last_num');
					if (!$num) $num = 0;
					$num = $num + 1;
				} else {
					$num = 0;
				}
				Mem::set('cart_last_day', $today);
				Mem::set('cart_last_num', $num);

				if ($num < 100) {
					$today = (int) ($today . '00');
					$id = $sym . ($today + $num);
				} else {
					$id = $sym . $today . $num;
				}



				$src = Cart::getPath($id);
			}
			$order['id'] = $id;
			//Добавляем в заявки пользователя
			Cart::catchOrder($order);
		} else {
			if ($place) Session::set([$place, $id]); //Удаляем автосохранение
			$src = Cart::getPath($id);
		}

		$myemail = Session::getEmail();
		if ($myemail != $order['email']) {
			Cart::catchOrder($order, $order['email']);
		}


		$rules = Load::loadJSON('-cart/rules.json');
		if (!empty($rules['rules'][$order['status']]['freeze'])) { //Текущий статус должен замораживать позиции
			Each::foro($order['basket'], function & (&$pos, $prodart) {
				$r = null;
				if (!empty($pos['article'])) return $r;
				$p = Cart::getByProdart($prodart);
				if ($p) { //Товар найден в каталоге
					$pos = array_merge($p, array('count' => $pos['count']));
					unset($pos['items']);
					unset($pos['itemrows']);
					$pos['hash'] = Cart::getPosHash($p); //Метка версии замороженной позиции
				}
				return $r;
			});
		} else { //Текущий статус не замораживает позиции
			Each::foro($order['basket'], function & (&$pos, $prodart) {
				$r = null;
				if (empty($pos['article'])) return $r;
				$pos = array(
					'count' => $pos['count']
				);
				return $r;
			});
		}

		if ($order['status'] == 'active') {
			//Сохраняем активную заявку без лишних данных, нужно хронить её номер чтобы другая заявка не заняла
			$order['fixid'] = $id;
			unset($order['id']); //У активной заявки нет id
			$oldactive = Session::get('orders.my');
			if (!empty($oldactive['fixid'])) { //Освобождаем старую активную заявку
				unlink(Path::resolve(Cart::getPath($oldactive['fixid'])));
			}

			//unset($order['manage']);//Сообщение менеджера удаляется
			if (empty($order['phone'])) $order['phone'] = '';
			if (empty($order['name'])) $order['name'] = '';

			Session::set('orders.my', $order); //Исключение, данные заявки


			$save = array(
				'email' => Session::getEmail(), //Тот пользователь который сделал заявку активной или последний кто с ней работал
				'name' => $order['name'],
				'phone' => $order['phone'],
				'status' => 'active',
				'time' => time()
			);
		} else {
			unset($order['fixid']);
			if ($place == 'orders' || empty($order['time'])) {
				$order['time'] = time();
			}
			$order['id'] = $id;
			$save = $order;
		}
		file_put_contents(Path::resolve((Cart::getPath()) . $id . '.json'), Load::json_encode($save));
	}
	public static function getPosHash($pos)
	{
		$conf = Config::get('cart');
		if (!isset($pos['Цена'])) $pos['Цена'] = '';
		else return md5($pos['Цена']);
	}
	//Серверу нужно говорить какой язык нужен
	public static function lang($lang, $str)
	{
		return Lang::lang($lang, 'cart', $str);
	}
	// public static function lang($str = null)
	// {
	// 	if (is_null($str)) return Lang::name('cart');
	// 	return Lang::str('cart', $str);
	// }
	public static function ret($ans, $action)
	{
		$rules = Load::loadJSON('-cart/rules.json');
		$order = $ans['order'];
		$rule = $rules['actions'][$action];
		// if ($ans['place'] != 'admin'  && !empty($order['email'])) { //Админ сам решает когда, что отправлять
		// 	if (!empty($rule['usermail'])) {
		// 		Cart::mail('user', $order['email'], $rule['usermail'], $ans['order']);
		// 	}
		// 	if (!empty($rule['mangmail'])) {
		// 		Cart::mail('manager', $order['email'], $rule['mangmail'], $order);
		// 	}
		// }

		if (!empty($order['email'])) {
			//Клиент отправляет письма менеджеру и себе
			//Менеджер только клиенту отправляет письма
			if (!empty($rule['usermail'])) {
				$ogood = Cart::getGoodOrder($order);
				Cart::mail('user', $order['email'], $rule['usermail'], $ogood);
			}

			if ($ans['place'] == 'orders') {
				if (!empty($rule['mangmail'])) {
					$ogood = Cart::getGoodOrder($order);
					Cart::mail('manager', $order['email'], $rule['mangmail'], $ogood);
				}
			}
		}

		return Ans::ret($ans);
	}
}
*/