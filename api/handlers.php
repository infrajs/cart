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
use infrajs\cart\api\Meta;

$context->handlers = [
	"Check the legality of the action" => function () {
		extract($this->gets(['order_id#', 'place','rule','user', 'user_id']));
		if ($place != 'admin' && !Cart::isOwner($order_id, $user_id)) return $this->err('CR003');
		if (in_array('post', $this->actionmeta['handlers'])
			&& !in_array('admin', $this->actionmeta['handlers'])
			&& !in_array('status', $this->actionmeta['handlers']) 
			&& !in_array('edit', $this->actionmeta['handlers']) 
		) {
			$actions = [];
			if (!empty($rule['actions'][$place])) {
				$obj = $rule['actions'][$place];
				if (isset($obj['actions'])) $actions += $obj['actions'];
				if (isset($obj['buttons'])) $actions += array_keys($obj['buttons']);
			}
			$actions = array_unique($actions);

			if (!in_array($this->actionmeta['action'], $actions)) return $this->fail('CR063');
		}
	},
	'post' => function () {
		$submit = ($_SERVER['REQUEST_METHOD'] === 'POST' || Ans::GET('submit', 'bool'));
		if (!$submit) return $this->fail('lang.post');
	},
	'admin' => function () {
		extract($this->gets(['user']));
		if (empty($user['admin'])) return $this->fail('CR003');
	},
	"paid" => function () {
		extract($this->gets(['order_id']));
		$paid = Db::col('SELECT paid FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if ($paid) return $this->fail('CR056');
	},
	"edit" => function () {
		extract($this->gets(['order_id#?','rule?','place']));
		if (!$order_id) return;
		if (empty($rule['actions'][$place]['edit'])) return $this->fail('CR003');
	},
	"checkstatus" => function () {
		extract($this->gets(['order_id#?']));
		$status = Db::col('SELECT status FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if (!$order_id) return;
		if ($status == $this->actionmeta['action']) return $this->fail('CR031');
		if (!in_array($status, $this->actionmeta['statuses'])) return $this->fail('CR031');
	},
	"checkdata" => function () {
		extract($this->gets(['order_id','rule']));
		$order = Cart::getById($order_id);
		if (empty($order['basket'])) return $this->err('CR020');
		if (empty($order['name'])) return $this->err('CR026');
		if (empty($order['phone'])) return $this->err('5');
		if (empty($order['email'])) return $this->err('CR005');

		if (empty($order['transport'])) return $this->err('trans');
		if (empty($order['pay'])) return $this->err('pay');
		if (in_array($order['transport'],["city","cdek_courier","pochta_courier"])) {
			if (empty($order['address'])) $this->err('address');
		}
		if (in_array($order['transport'],["pochta_simple","pochta_1"])) {
			//if (empty($order['zip'])) return $this->err('zip');
			if (empty($order['address'])) return $this->err('address');
		}
		if (in_array($order['transport'],["cdek_pvz"])) {
			//if (empty($order['pvz'])) return $this->err('pvz');
		}
	},
	"freeze" => function () {
		extract($this->gets(['order_id']));
		if (!Cart::freeze($order_id)) return $this->fail('CR018');
	},
	"unfreeze" => function () {
		extract($this->gets(['order_id']));
		if (!Cart::unfreeze($order_id)) return $this->fail('CR018');
	},
	
	"create_order_user" => function () {
		extract($this->gets(['ans','order', 'user', 'lang', 'city_id','timezone']));
		
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
			
			$r = Cart::setOwner($order['order_id'], $ouser['user_id']);
			if (!$r) return $this->fail('CR018');
		} else { //Если на указанный email уже есть регистрация
			if ($ouser['user_id'] != $user['user_id']) { //и это не мы
				
				if (empty($user['email'])) { 
					//Текущий пользователь не зарегистрирован, ему нужно просто перейти в свой аккаунт
					$ouser['order'] = $order;
					$r = User::mail($ouser, $lang, 'userdata', '/cart/orders/active');
					if (!$r) return $this->err('CR023');
					return $this->err('CR022');	
				} else {
					//У текущего пользователя есть аккаунт, ему не надо переходить, но нужно дать доступ и пользователю по указанному email
					//Передаём доступ к текущему заказу и на этот аккаунт и делает для нового аккаунта этот заказ активным?. Злоумышленник кому-то может подсунуть новый заказ)
					Cart::setOwner($order['order_id'], $ouser['user_id']);
					if (!$r) return $this->fail('CR018');
					//И пропускаем оформление заказа дальше
				}
				
			} else {
				$r = Cart::setOwner($order['order_id'], $ouser['user_id']);
				if (!$r) return $this->fail('CR018');	
			}
		}	
		
		Cart::recalc($order['order_id']);
		$order = Cart::getById($order['order_id']);
	}
];