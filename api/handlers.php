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
		extract($this->gets(['place','rule','order_id','user', 'user_id'], 'i'.__LINE__));
		if ($place != 'admin' && !Cart::isOwner($order_id, $user_id)) return $this->err('CR003', 'v'.__LINE__);
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

			if (!in_array($this->actionmeta['action'], $actions)) return $this->fail('CR003', 'i'.__LINE__);
		}
	},
	'post' => function () {
		$submit = ($_SERVER['REQUEST_METHOD'] === 'POST' || Ans::GET('submit', 'bool'));
		if (!$submit) return $this->fail('lang.post', 'i'.__LINE__);
	},
	'admin' => function () {
		extract($this->gets(['user'],__LINE__));
		if (empty($user['admin'])) return $this->fail('CR003', 'i'.__LINE__);
	},
	"paid" => function () {
		extract($this->gets(['order_id'], 'i'.__LINE__));
		$paid = Db::col('SELECT paid FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if ($paid) return $this->fail('CR056', 'i'.__LINE__);
	},
	"edit" => function () {
		extract($this->gets(['order_id','rule','place'], 'i'.__LINE__));
		if (empty($rule['actions'][$place]['edit'])) return $this->fail('CR003', 'i'.__LINE__);
	},
	"checkstatus" => function () {
		extract($this->gets(['order_id'], 'i'.__LINE__));
		$status = Db::col('SELECT status FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if ($status == $this->actionmeta['action']) return $this->fail('CR031', 'i'.__LINE__);
		if (!in_array($status, $this->actionmeta['statuses'])) return $this->fail('CR031', 'i'.__LINE__);
	},
	"checkdata" => function () {
		extract($this->gets(['order_id','rule'], 'i'.__LINE__));
		$order = Cart::getById($order_id);
		if (empty($order['basket'])) return $this->err('CR020', 'i'.__LINE__);
		if (empty($order['name'])) return $this->err('CR026', 'i'.__LINE__);
		if (empty($order['phone'])) return $this->err('5', 'i'.__LINE__);
		if (empty($order['email'])) return $this->err('CR005', 'i'.__LINE__);

		if (empty($order['transport'])) return $this->err('trans', 'i'.__LINE__);
		if (empty($order['pay'])) return $this->err('pay', 'i'.__LINE__);
		if (in_array($order['transport'],["city","cdek_courier","pochta_courier"])) {
			if (empty($order['address'])) $err('address', 'i'.__LINE__);
		}
		if (in_array($order['transport'],["pochta_simple","pochta_1"])) {
			if (empty($order['zip'])) return $this->err('zip', 'i'.__LINE__);
			if (empty($order['address'])) return $this->err('address', 'i'.__LINE__);
		}
		if (in_array($order['transport'],["cdek_pvz"])) {
			if (empty($order['pvz'])) return $this->err('pvz', 'i'.__LINE__);
		}
	},
	"freeze" => function () {
		extract($this->gets(['order_id'], 'i'.__LINE__));
		if (!Cart::freeze($order_id)) return $this->fail('CR018', 'i'.__LINE__);
	},
	"unfreeze" => function () {
		extract($this->gets(['order_id'], 'i'.__LINE__));
		if (!Cart::unfreeze($order_id)) return $this->fail('CR018', 'i'.__LINE__);
	},
	
	"create_order_user" => function () {
		extract($this->gets(['ans','order', 'user', 'lang'], 'i'.__LINE__));
		
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
					$r = User::mail($ouser, $lang, 'userdata', '/cart/orders/active');
					if (!$r) return $this->err($ans, $lang, 'CR023.a' . __LINE__);
					return $this->err($ans, $lang, 'CR022.a' . __LINE__);	
				} else {
					//У текущего пользователя есть аккаунт, ему не надо переходить, но нужно дать доступ и пользователю по указанному email
					//Передаём доступ к текущему заказу и на этот аккаунт и делает для нового аккаунта этот заказ активным?. Злоумышленник кому-то может подсунуть новый заказ)
					Cart::setOwner($order['order_id'], $ouser['user_id']);
					//И пропускаем оформление заказа дальше
				}
				
			}
		}	
		$r = Cart::setOwner($order['order_id'], $ouser['user_id']);
		if (!$r) return $this->fail($ans, $lang, 'CR018.a' . __LINE__);
		Cart::recalc($order['order_id']);
		$order = Cart::getById($order['order_id']);
	}
];