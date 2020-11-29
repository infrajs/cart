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
use infrajs\cart\cdek\CDEK;
use infrajs\cart\pochta\Pochta;

class Cart
{
	public static $conf = [];
	public static $name = 'cart';
	use CacheOnce;
	use LangAns;
	use UserMail;
	public static function mailbefore(&$user)
	{
		$order = $user['order'];
		$city_id = $user['order']['city_id'] ? $user['order']['city_id'] : $user['city_id'];
		$user['order']['city'] = City::getById($city_id, $user['lang']);
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
		$check = Db::col('SELECT order_nick from cart_orders where order_nick = :order_nick', [
			':order_nick' => $nick
		]);
		if ($check) return Cart::createNick();
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
	public static function getOrders($fuser, $status, $start, $end)
	{
		//$fuser = [];
		$status = false;
		return static::once('getOrders', [$fuser, $status, $start, $end], function ($fuser, $status, $start, $end) {
			$fields = 'o.order_nick, o.order_id, o.status, o.sum, o.name, o.email, o.coupon, o.paid';
			$fields = 'o.order_id';
			$param = [];
			if ($start) {
				$param[":start"] = $start;
				$param[":end"] = $end;
				$time = '((datecheck is not null and datecheck >= FROM_UNIXTIME(:start) and datecheck < FROM_UNIXTIME(:end)) or (datecheck is null and dateedit >= FROM_UNIXTIME(:start) and dateedit < FROM_UNIXTIME(:end)))';
			} else {
				$time = 'o.order_id is not null';
			}

			if ($fuser) {
				$param[':user_id'] = $fuser['user_id'];
				$sql = "SELECT DISTINCT $fields
					FROM cart_orders o
					RIGHT JOIN cart_userorders ou on (ou.user_id = :user_id and ou.order_id = o.order_id)
					WHERE $time
				";
			} else {
				if ($status) {
					$param[':status'] = $status;
					if ($fuser) {
						$param[':user_id'] = $fuser['user_id'];
						$sql = "SELECT DISTINCT $fields
							FROM cart_orders o
							RIGHT JOIN cart_userorders ou on (ou.user_id = :user_id and ou.order_id = o.order_id)
							WHERE $time
							and o.status = :status
						";
					} else {
						$sql = "SELECT DISTINCT $fields
							FROM cart_orders o
							WHERE $time and o.status = :status
						";
					}
				} else {
					// $sql = "SELECT DISTINCT $fields
					// 	FROM cart_orders o
					// 	WHERE $time AND o.status != 'wait' AND o.status != ''
					// ";
					$sql = "SELECT DISTINCT $fields
						FROM cart_orders o
						WHERE $time
					";
				}
			}
			$sql .= 'ORDER BY o.dateedit DESC';

			$list = Db::colAll($sql, $param);

			foreach ($list as $k => $order_id) {
				$list[$k] = Cart::getById($order_id, true);
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
		$sql = 'SELECT UNIX_TIMESTAMP(min(datecreate)) as start FROM cart_orders';
		$end = time();
		$start = Db::col($sql) ?? $end - 1;
		//$start -= 60 * 60 * 24 * 30 * 20;
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

		$list[$runyear][sizeof($list[$runyear])-1]['now'] = true;

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
	public static function create($user_id)
	{
		$user = Db::fetch('SELECT email, city_id FROM users WHERE user_id = :user_id', [
			':user_id' => $user_id
		]);

		$fields = ['name','phone','address','zip','transport','city_id','pay','pvz'];
		$fieldsstr = implode(',', $fields);
		$row = Db::fetch("SELECT $fieldsstr from cart_orders where email = :email order by dateedit DESC", [
			':email'=> $user['email']
		]);
		if (!$row) {
			$row = array_flip($fields);
			foreach($row as $i => $v) $row[$i] = '';
			$row['transport'] = 'cdek_pvz';
			$row['pay'] = 'card';
			$row['city_id'] = $user['city_id'];
		}
		$row['email'] = $user['email'];
		$row['order_nick'] = Cart::createNick();
		$fieldsstr = implode(',', array_keys($row));
		$param = array_values($row);
		$valuestr = implode(',', array_fill(0, sizeof($param), '?'));

		$order_id = Db::lastId("INSERT INTO cart_orders ($fieldsstr, datecreate, datewait, dateedit) 
			VALUES($valuestr, now(),now(),now())", $param);
		if (!$order_id) return false;
		
		Db::exec('INSERT INTO cart_userorders (user_id, order_id, active) VALUES(:user_id, :order_id, 1)', [
			':user_id' => $user_id, 
			':order_id' => $order_id
		]);
		return $order_id;
	}
	public static function getActiveOrder($user_id)
	{
		return static::once('getActiveOrder', $user_id, function ($user_id) {
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
		return $pos['article_nick'] . $pos['producer_nick'] . $pos['item_num'] . $pos['catkit'];
	}
	// public static function getModelTitle($model)
	// {
	// 	return $model['Наименование'];
	// }
	public static function addModel($order_id, $model, $count = false)
	{
		$pos = Db::fetch('SELECT position_id, count FROM cart_basket 
			WHERE order_id = :order_id and catkit = :catkit and item_num = :item_num and article_nick = :article_nick and producer_nick = :producer_nick', [
			':order_id' => $order_id,
			':article_nick' => $model['article_nick'],
			':producer_nick' => $model['producer_nick'],
			':item_num' => $model['item_num'],
			':catkit' => !empty($model['kit']) ? $model['catkit'] : ''
		]);
		if ($count === true) {
			if (!empty($pos['count'])) return true;
			$count = 1;
		}
		if (!$pos) {
			$position_id = Db::lastId('INSERT IGNORE INTO cart_basket (
				order_id, article_nick, producer_nick, item_num, catkit, count, dateadd, dateedit
			) VALUES (
				:order_id, :article_nick, :producer_nick, :item_num, :catkit, :count, now(), now()
			)', [
				':order_id' => $order_id,
				':article_nick' => $model['article_nick'],
				':producer_nick' => $model['producer_nick'],
				':item_num' => $model['item_num'],
				':catkit' => !empty($model['kit']) ? $model['catkit'] : '',
				':count' => 0
			]);
		} else {
			$position_id = $pos['position_id'];
		}
		return Cart::add($order_id, $position_id, $count);
	}
	public static function add($order_id, $position_id, $count = false)
	{
		$r = Db::exec('UPDATE cart_basket
			SET count = :count, dateedit = now()
			WHERE position_id = :position_id
		', [
			':position_id' => $position_id,
			':count' => $count
		]) !== false;
		if (!$r) return false;

		$r = Db::exec('UPDATE cart_orders
			SET dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return false;

		if ($count === false) {
			$sql = 'DELETE FROM cart_basket WHERE position_id = :position_id';
			$r = Db::exec($sql, [
				':position_id' => $position_id
			]) !== false;
		} else {
			$freeze = Db::col('SELECT order_id FROM cart_orders WHERE order_id = :order_id', [
				':order_id' => $order_id
			]);
			if ($freeze) {
				$pos = Db::fetch('SELECT article_nick, producer_nick, item_num, catkit from cart_basket 
					where position_id = :position_id', [
					':position_id'=> $position_id
				]);
				$model = Cart::getFromShowcase($pos);
				if (!Cart::setToJson($position_id, $model)) return false;
			}
		}

		$r = Cart::recalc($order_id);
		return $r;

		 
			// //update
			// $position_id = Db::col('SELECT position_id FROM cart_basket 
			// 	WHERE order_id = :order_id and catkit = :catkit and item_num = :item_num and article_nick = :article_nick and producer_nick = :producer_nick', [
			// 	':order_id' => $order['order_id'],
			// 	':article_nick' => $model['article_nick'],
			// 	':producer_nick' => $model['producer_nick'],
			// 	':item_num' => $model['item_num'],
			// 	':catkit' => !empty($model['kit']) ? $model['catkit'] : ''
			// ]);
			// if (!$position_id) return false;

			
		//}

		
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
	public static function setLang($order_id, $lang)
	{
		$sql = 'UPDATE cart_orders
			SET lang = :lang
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order_id,
			':lang' => $lang
		]) !== false;
		return $r;
	}
	public static function setTransport($order_id, $transport)
	{
		$r = Db::exec('UPDATE cart_orders
			SET transport = :transport, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':transport' => $transport
		]) !== false;
		//if (!$r) return false;
		//$r = Cart::recalc($order_id);
		return $r;
	}
	public static function setCommentManager($order_id, $commentmanager)
	{
		$sql = 'UPDATE cart_orders
			SET commentmanager = :commentmanager
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order_id,
			':commentmanager' => $commentmanager
		]) !== false;
		return $r;
	}
	public static function setPay($order_id, $pay)
	{
		$r = Db::exec('UPDATE cart_orders
			SET pay = :pay, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':pay' => $pay
		]) !== false;
		// if (!$r) return $r;
		// $r = Cart::recalc($order['order_id']);
		return $r;
	}
	public static function getCity($city_id, $email, $order_id, $lang) {
		if (!$city_id) {
			$fuser = User::getByEmail($email);
			if (!$fuser) {
				$user_id = Db::col('SELECT user_id from cart_userorders WHERE order_id = :order_id ORDER BY active DESC', [
			 		':order_id' => $order_id
				]);
				$fuser = User::getById($user_id);
				if (!$fuser) return false;
			}
			$city_id = $fuser['city_id'];
		}
		return City::getById($city_id, $lang);
	}
	public static function setCoupon($order_id, $coupon, $coupondata)
	{
		//При изменении позиции в каталоге. Позиция не пересчитыватся. 
		//Но пересчитывается перед freeze.
		//Купон фризится в момент установки и применяется в поле discount у каждой позиции

		$r = Db::exec('UPDATE cart_orders
			SET coupon = :coupon, coupondata = :coupondata, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':coupon' => $coupon,
			':coupondata' => json_encode($coupondata, JSON_UNESCAPED_UNICODE)
		]) !== false;
		if (!$r) return false;
		$r = Cart::recalc($order_id);
		return $r;
	}
	public static function setCallback($order_id, $callback)
	{
		$r = Db::exec('UPDATE cart_orders
			SET callback = :callback, dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':callback' => $callback
		]) !== false;
		return $r;
	}
	public static function setCity($order, $city_id)
	{
		if (!$city_id) return false;
		//if ($order['city_id'] == $city_id) return true;
		$sql = 'UPDATE cart_orders
			SET city_id = :city_id, zip = "", pvz = "", dateedit = now()
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
		$r = Cart::resetUserActive($user_id);
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
		$order_id = $order['order_id'];
		$sql = 'DELETE b FROM cart_basket b
			WHERE b.order_id = :order_id 
		';
		if (Db::exec($sql, [
			':order_id' => $order_id
		]) === false) return false;

		$r = Db::exec('UPDATE cart_orders
			SET dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return false;

		$r = Cart::recalc($order_id);
		return $r;
	}
	public static function removePos($position_ids, $user)
	{
		$order_id = Db::col('SELECT DISTINCT order_id FROM cart_basket where position_id in (' . implode(',', $position_ids) . ')');
		if (!$order_id) return true; //Позиции нет

		$sql = 'DELETE b FROM cart_basket b
			WHERE b.position_id in (' . implode(',', $position_ids) . ')
		';
		if (Db::exec($sql) === false) return false;
		
		$r = Db::exec('UPDATE cart_orders
			SET dateedit = now()
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return false;

		$r = Cart::recalc($order_id);
		return $r;
	}
	public static function clearTransportCost($order_id) {
		$r = Db::exec('DELETE FROM cart_transports WHERE order_id = :order_id', [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return $r;

		$r = Db::exec('UPDATE cart_orders
			SET count = :count, weight = :weight
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':weight' => null,
			':count' => null
		]) !== false;
		return $r;
	}
	public static function saveTransportCost($order_id, $type, $cost, $min, $max)
	{
		$sql = 'INSERT INTO
			cart_transports
		SET
			order_id = :order_id, 
			type = :type, 
			cost = :cost, 
			min = :min, 
			max =:max
		ON DUPLICATE KEY UPDATE
			cost = :cost, 
			min = :min, 
			max =:max';


		// if (!isset($order['transport'][$type])) {
		// 	$sql = 'INSERT IGNORE INTO cart_transports (order_id, type, cost, min, max) VALUES(:order_id, :type, :cost, :min, :max)';
		// } else {
		// 	$sql = 'UPDATE cart_transports SET cost = :cost, min = :min, max = :max
		// 	WHERE order_id = :order_id and type = :type';
		// }
		$r = Db::exec($sql, [
			':order_id' => $order_id,
			':type' => $type,
			':cost' => $cost,
			':min' => $min,
			':max' => $max
		]) !== false;
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
	public static function getDiscount($order_id, $model) {
		$coupondata = Db::col('SELECT coupondata FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if (!$coupondata) return 0;
		$coupondata = json_decode($coupondata, true);
		if (!$coupondata) return 0;
		$res = Cart::couponCheck($model, $coupondata);
		if (!$res) return 0;
		return $coupondata['Скидка'];
	}
	public static function getWeight($model) {
		return $model['Вес, кг'] ?? $model['more']['Вес, кг'] ?? false;
	}
	public static function getDim($model) {
		//$model['Габариты']//WxHxL
		$model += $model['more'] ?? [];
		$dim = $model['Упаковка, см'] ?? $model['Габариты, см'] ?? $model['Габариты'] ?? '';
		$d = preg_split('/[хx]/i', $dim, 3, PREG_SPLIT_NO_EMPTY);
		$d[0] = $d[0] ?? $model['Длина, см'] ?? $model['Длина (см)'] ?? false;
		$d[1] = $d[1] ?? $model['Ширина, см'] ?? $model['Ширина (см)'] ?? false;
		$d[2] = $d[2] ?? $model['Высота, см'] ?? $model['Высота (см)'] ?? false;

		if (!$d[0] || !$d[1] || !$d[2]) return false;
		$weight = Cart::getWeight($model);
		if (!$weight) return false;
		
		$weight = (float) $weight; //Должно быть в кг

		return [
			"max" => max($d[0],$d[1],$d[2]),
			"min" => min($d[0],$d[1],$d[2]),
			"width" => $d[0], 
			"height" => $d[1], 
			"length" => $d[2], 
			"weight" => $weight
		];
	}
	public static function recalc($order_id)
	{
		//Меняются 
		//discount - надо установить при добавлении позиции, 
		//transports - надо пересчитать при добавлении позиции
		
		static::$once = [];

		$basket = Db::all('SELECT position_id, discount, count from cart_basket where order_id = :order_id FOR UPDATE', [
			':order_id' => $order_id
		]);
		
		
		$sum = 0;
		$count = 0;
		$weight = 0;
		
		$usepochta = true;
		$sizeerror = false;
		foreach ($basket as $k => $pos) {
			$model = Cart::getModel($pos['position_id']);
			if (!$model) continue;
			$dim = Cart::getDim($model);
			if (!$dim) {
				$sizeerror = true;
				break;
			}
			$w = $dim['weight'];
			if (!$w) {
				$sizeerror = true;
				break;	
			}
			
			if ($dim['max'] > Pochta::$limit['max'] || $dim['min'] > Pochta::$limit['min']) {
				$usepochta = false;
			}

			$weight += $w * $pos['count'];
			
			$count++;
			$discount = Cart::getDiscount($order_id, $model);
			$r = Db::exec('UPDATE cart_basket
				SET discount = :discount
				WHERE position_id = :position_id
			', [
				':position_id' => $pos['position_id'],
				':discount' => $discount ? $discount * 100 : null
			]) !== false;
			$discount = 1 - $pos['discount'] / 100;
			$sum += $model['Цена'] * $discount * $pos['count'];
		}
		Cart::clearTransportCost($order_id);
		//order: city_id, basket - размеры, вес, 

		$order = Db::fetch('SELECT city_id, zip, email, transport FROM cart_orders where order_id = :order_id FOR UPDATE', [
			':order_id' => $order_id
		]);

		$city = Cart::getCity($order['city_id'], $order['email'], $order_id, 'ru');


		$transports = Cart::$conf['transports'];
		

		$transportfree = Cart::$conf['transportfree'] ?? 100000000;


		

		
		$mytransport = [];

		if ($city) { //В какой ситуации может не быть города? база данных поменялась и по city_id ничего не нашлось...

			$city_to_id = $city['city_id'];
			$city_from_id = Cart::$conf['city_from_id'];

			if ($city_from_id == $city_to_id) {
				
				$type = 'city'; $cost = 100;
				$cost = ($sum >= $transportfree) ? 0 : $cost;
				if (in_array($type, $transports)) {
					$mytransport[] = $type;
					Cart::saveTransportCost($order_id, $type, $cost, 1, 1);
				}

				$type = 'self'; $cost = 0;
				$cost = ($sum >= $transportfree) ? 0 : $cost;
				if (in_array($type, $transports)) {
					$mytransport[] = $type;
					Cart::saveTransportCost($order_id, $type, $cost, 0, 0);	
				}
			}

			//Если Весь больше 5 кг или Сумма заказа больше 10 000 руб.
			//if ($sum > 10000 || $weight > 5 || !$usepochta) {
				$type = 'any'; $cost = 0;
				$cost = ($sum >= $transportfree) ? 0 : $cost;
				if (in_array($type, $transports)) {
					$mytransport[] = $type;
					Cart::saveTransportCost($order_id, $type, $cost, 0, 0);
				}
			//}

			
			if (!$sizeerror) {
				//"pickup","courier",
				$goods = CDEK::getGoods($basket);

				$type = 'cdek_pvz';
				if ($goods && in_array($type, $transports)) {
					$ans = CDEK::calc($goods, "pickup", $city_to_id);
					if ($ans) {
						$cost = $ans['cost'];
						$min = $ans['min'];
						$max = $ans['max'];
						$cost = ($sum >= $transportfree) ? 0 : $cost;
						if (in_array($type, $transports)) {
							$mytransport[] = $type;
							Cart::saveTransportCost($order_id, $type, $cost, $min, $max);
						}
					}
				}

				$type = 'cdek_courier'; 
				if ($goods && in_array($type, $transports)) {
					$ans = CDEK::calc($goods, "courier", $city_to_id);
					if ($ans) {
						$cost = $ans['cost'];
						$min = $ans['min'];
						$max = $ans['max'];
						$cost = ($sum >= $transportfree) ? 0 : $cost;
						if (in_array($type, $transports)) {
							$mytransport[] = $type;
							Cart::saveTransportCost($order_id, $type, $cost, $min, $max);
						}
					}
				}

				if ($usepochta) {
					$zip = $order['zip'] ? $order['zip'] : $city['zip'];
					$type = 'pochta_simple';
					$ans = Pochta::calc($type, $weight, $zip);
					if ($ans) {
						$cost = $ans['cost'];
						$min = $ans['min'];
						$max = $ans['max'];
						$cost = ($sum >= $transportfree) ? 0 : $cost;
						if (in_array($type, $transports)) {
							$mytransport[] = $type;
							Cart::saveTransportCost($order_id, $type, $cost, $min, $max);
						}
					}

					$type = 'pochta_1'; 
					$ans = Pochta::calc($type, $weight, $zip);
					if ($ans) {
						$cost = $ans['cost'];
						$min = $ans['min'];
						$max = $ans['max'];
						$cost = ($sum >= $transportfree) ? 0 : $cost;
						if (in_array($type, $transports)) {
							$mytransport[] = $type;
							Cart::saveTransportCost($order_id, $type, $cost, $min, $max);
						}
					}
					$type = 'pochta_courier';
					$ans = Pochta::calc($type, $weight, $zip);
					if ($ans) {
						$cost = $ans['cost'];
						$min = $ans['min'];
						$max = $ans['max'];
						$cost = ($sum >= $transportfree) ? 0 : $cost;
						if (in_array($type, $transports)) {
							$mytransport[] = $type;
							Cart::saveTransportCost($order_id, $type, $cost, $min, $max);
						}
					}
				}
			}

			//Доставка
			//Купон применяется к позиции. Результат с купоном хранится в описании позиции в корзине, так как его нужно замораживать и не пересчитывать для freeze
			//У позиции есть ценаsum - после скидки и cost*count до скидки.
		}
		$transport = in_array($order['transport'], $mytransport) ? $order['transport'] : null;

		$r = Db::exec('UPDATE cart_orders
			SET count = :count, weight = :weight, transport = :transport
			WHERE order_id = :order_id
		', [
			':order_id' => $order_id,
			':transport' => $transport,
			':weight' => $weight * 1000,
			':count' => $count
		]) !== false;
		if (!$r) return $r;
		
		return $r;
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
	public static function setStatus($order_id, $status, $noedit = false)
	{
		if ($noedit) {
			$sql = 'UPDATE cart_orders
				SET status = :status
				WHERE order_id = :order_id
			';	
		} else {
			$sql = "UPDATE cart_orders
				SET status = :status, 
				dateedit = now(),
				date$status = now()
				WHERE order_id = :order_id
			";	
		}
		
		if (Db::exec($sql, [
			':order_id' => $order_id,
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

	public static function getById($order_id, $fast = false)
	{
		return static::once('getById', [$order_id, $fast], function ($order_id, $fast) {
			$sql = 'SELECT 
					order_id, 
					status,
					name,
					phone,
					callback,
					transport,
					pay,
					paydata,
					city_id,
					freeze,
					count,
					weight,
					coupon,
					coupondata,
					paid,
					order_nick, 
					email, 
					address,
					zip,
					pvz,
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

			if ($order['weight']) $order['weight'] = $order['weight'] / 1000;
			
			if ($order['paydata']) {
				$order['paydata'] = json_decode($order['paydata'], true);
				unset($order['paydata']['key']);
				unset($order['paydata']['card_number']);
				unset($order['paydata']['fop_receipt_key']);
				unset($order['paydata']['fop_receipt_key']);
			}
			if ($order['coupondata']) $order['coupondata'] = json_decode($order['coupondata'], true);

			

			// $user_id = Db::col('SELECT user_id from cart_userorders WHERE order_id = :order_id ORDER BY active DESC', [
			// 	':order_id' => $order_id
			// ]);
			// if (!$user_id) return false; //Если нет ни одного владельца у заказа
			// $order['user_id'] = $user_id;
			// $order['user'] = User::getById($user_id);//Этот user может быть без email
			// unset($order['user']['token']);
			// unset($order['user']['password']);
			// $city_id = $order['city_id'] ? $order['city_id'] : $order['user']['city_id'];
			// $order['city'] = City::getById($city_id, $order['user']['lang']);
			// $order['city']['zips'] = City::getIndexes($city_id);
			
			$order['paid'] = (bool) $order['paid'];

			$order['basket'] = Db::all('SELECT 
					position_id,
					producer_nick,
					article_nick,
					item_num,
					catkit,
					costclear,
					hash,
					discount,
					count
				FROM cart_basket 
				WHERE order_id = :order_id
				order by dateadd DESC
			', ['order_id' => $order_id]);

			//Если заказ оплачен, сумма оплаты будет в paydata, также оплату можно посчитать, так как заказ будет нередактируемым и замороженным
			$order['sum'] = 0;
			$order['sumclear'] = 0;
			$count = 0;

			foreach ($order['basket'] as $i => $pos) {
				
				if ($fast) {
					if ($order['freeze']) {
						$costclear = $pos['costclear'];
					} else {
						$costclear = Showcase::getCost($pos['producer_nick'], $pos['article_nick'], $pos['item_num']);
						if (!$costclear) {
							unset($order['basket'][$i]);
							continue; //Модель не заморожена и не найдена в каталоге
						}

					}
				} else {
					$model = Cart::getModel($pos['position_id']);
					if (!$model) {
						unset($order['basket'][$i]);
						continue; //Модель не заморожена и не найдена в каталоге
					}
					$order['basket'][$i]['model'] = $model;
					$costclear = $model['Цена']; //Цену надо взять или из каталога
					Db::exec('UPDATE cart_basket
						SET costclear = :costclear
						WHERE position_id = :position_id', [
							':position_id' => $pos['position_id'],
							':costclear' => $costclear
					]);
					
				}
				$count++;
				/*
					Полагаемся на Цена, discount, count
				*/
				
				$order['basket'][$i]['costclear'] = $costclear;
				$order['basket'][$i]['sumclear'] = $costclear * $pos['count'];
				$discount = (100 - $pos['discount']) / 100;
				$cost = $costclear * $discount;
				$sum = $cost * $pos['count'];

				$order['basket'][$i]['sum'] = $sum;
				$order['basket'][$i]['cost'] = $cost;
				$order['sum'] += $sum;
				$order['sumclear'] += $order['basket'][$i]['sumclear'];
				
			}

			if ($fast) {

			} else {
				if ($order['count'] != $count) { //Пропала позиция в каталоге с последнего пересчёта через showcase (не было нового вызова пересчёта)
					Cart::recalc($order_id); //влияет только на transports
				}
			}
			//Редактировать заявку может менеджер, и к user мы не можем обращаться. Надо знать email или phone, но у заказа они могут быть не указаны
			//$order['user'] = User::getByEmail($order['email']);
			// if ($order['email']) {
			// 	$order['user'] = User::getByEmail($order['email']);
			// }
			$order['transports'] = Db::allto('SELECT cost, min, max, type
				FROM cart_transports 
				WHERE order_id = :order_id
			', 'type', [
				'order_id' => $order_id
			]);

			$order['sumtrans'] = 0;
			if ($order['transport'] && isset($order['transports'][$order['transport']])) {
				$order['sumtrans'] = $order['transports'][$order['transport']]['cost'];	
			}
			$order['total'] = $order['sumtrans'] + $order['sum'];

			if ($order['pay'] == 'self' && in_array($order['transport'],['cdek_pvz', 'any', 'cdek_courier','pochta_simple','pochta_1','pochta_courier'])) {
				$order['total'] = round($order['total'] * 104) / 100;
			}
			

			return $order;
		});
	}
	public static function getHash($model)
	{
		if (!$model) return 'none';
		$hash = Path::encode($model['Цена']);
		//unset($model['model_id']);
		//$hash = md5(json_encode($model, JSON_UNESCAPED_UNICODE));
		return $hash;
	}

	public static function getFromJson($position_id)
	{
		//position_id, model_id, item_num, catkit, freeze, hash
		$sql = 'SELECT json from cart_basket WHERE position_id = :position_id';
		$json = Db::col($sql, [':position_id' => $position_id]);
		$model = json_decode($json, true);
		return $model;
	}

	public static function setToJson($position_id, $model)
	{
		$json = json_encode($model, JSON_UNESCAPED_UNICODE);
		$hash = Cart::getHash($model);
		$sql = 'UPDATE cart_basket
			SET json = :json, hash = :hash
			WHERE position_id = :position_id
		';

		$r = Db::exec($sql, [
			':position_id' => $position_id,
			':json' => $json,
			':hash' => $hash
		]) !== false;

		return $r;
	}
	public static function getModel($position_id) {
		return static::once('getModel', $position_id, function ($position_id) {
			$pos = Db::fetch('SELECT position_id, producer_nick, article_nick, item_num, catkit, hash FROM cart_basket WHERE position_id = :position_id',[
				':position_id' => $position_id
			]);
			$model = Cart::getFromShowcase($pos);
			//Ключ по которому определяется заморожена позиция или нет
			if ($pos['hash']) {
				$changed = $model ? $pos['hash'] !== Cart::getHash($model) : true;
				if ($changed) $model = Cart::getFromJson($position_id);
			} else {
				$changed = false;
			}
			if ($model) $model['changed'] = $changed;
			return $model;
		});
	}
	public static function getFromShowcase($pos)
	{
		//return Showcase::getModel($pos['producer_nick'], $pos['article_nick'], $pos['item_num'], $pos['catkit']);
		return Showcase::getModelEasy($pos['producer_nick'], $pos['article_nick'], $pos['item_num']);
	}
	public static function freeze($order_id)
	{
		$sql = 'UPDATE cart_orders
			SET freeze = 1
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return $r;

		$basket = Db::all('SELECT position_id, producer_nick, article_nick, item_num, catkit from cart_basket where order_id = :order_id', [
			':order_id' => $order_id
		]);

		foreach ($basket as $pos) {
			$model = Cart::getFromShowcase($pos);
			if (!$model) { //Модели нет в каталоге и эта модель не должна была попадать в расчёты
				$sql = 'DELETE FROM cart_basket WHERE position_id = :position_id';
				$r = Db::exec($sql, [
					':position_id' => $pos['position_id']
				]) !== false;
				if (!$r) return false;
				continue;
			}
			//Если модели нет в каталоге. надо удалить её из корзины. Такая проверка должна быть раньше.
			if (!Cart::setToJson($pos['position_id'], $model)) return false;

			//position_id, model_id, item_num, catkit, freeze, hash
			//$position_id = $pos['position_id']
		}
		$r = Cart::recalc($order_id); //Установятся актуальные цены
		return $r;
	}
	public static function unfreeze($order_id)
	{
		$sql = 'UPDATE cart_orders
			SET freeze = 0
			WHERE order_id = :order_id
		';
		$r = Db::exec($sql, [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return $r;

		$sql = 'UPDATE cart_basket
			SET json = null, hash = null
			WHERE order_id = :order_id
		';

		$r = Db::exec($sql, [
			':order_id' => $order_id
		]) !== false;
		if (!$r) return false;
		$r = Cart::recalc($order_id);
		return $r;
	}
	public static function getUsers($order_id)
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
		$users = Db::all($sql, ['order_id' => $order_id]);
		return $users;
	}


	public static function setOwner($order_id, $user_id)
	{
		if (Cart::isOwner($order_id, $user_id)) return true;
		$sql = 'INSERT INTO cart_userorders (user_id, order_id) VALUES(:user_id,:order_id)';
		return Db::exec($sql, [
			':user_id' => $user_id,
			':order_id' => $order_id
		]);
	}
	public static function isOwner($order_id, $user_id)
	{ //action true совпадёт с любой строчкой
		if (!$user_id) return false;
		$users = Cart::getUsers($order_id);
		foreach ($users as $u) {
			if ($u['user_id'] == $user_id) return true;
		}
		//Тут проверяется есть ли необходимое действие в списке действий с заявкой с таким статусом
		return false;
	}
};




























Event::$classes["Cart"] = function ($pos) {
	return $pos["producer_nick"] . $pos["article_nick"] . $pos["item_num"] . $pos['catkit'];
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