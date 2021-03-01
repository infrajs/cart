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

$context->vars = [
	'order' => function (&$order) {
		extract($this->gets(['order_id#']), EXTR_REFS);
		$order = Cart::getById($order_id);
	},
	'oemail' => function (&$oemail) {
		$this->handler('checkdata'); //Мы должны быть уверены что order с email есть
		extract($this->gets(['order']), EXTR_REFS);
		$oemail = $order['email'];

	},
	'ouser' => function (&$ouser) {
		extract($this->gets(['oemail']), EXTR_REFS);	
		$ouser = User::getByEmail($oemail);
	},
	'model' => function (&$model) {
		extract($this->gets(['producer_nick','article_nick','item_num','catkit']), EXTR_REFS);
		$pos = [
			'producer_nick' => $producer_nick,
			'article_nick' => $article_nick,
			'item_num' => $item_num,
			'catkit' => $catkit
		];
		$model = Cart::getFromShowcase($pos);
		if (!$model) throw $this::fail('CR013');
	},
	'order_id#' => function (&$order_id, $pname) {
		if (in_array('order_id', $this->actionmeta['required'])) {
			$order_id = $this->get('order_id');
			if (!$order_id) $order_id = $this->get('active_id#');
			if (!$order_id) return $this->fail('заказ не найден');
		} else {
			$order_nick = $this->get('order_nick');
			if ($order_nick == 'active') {
				$order_id = $this->get('active_id#?');
				if (!$order_id) return $this->fail('order_nick');
			} else {
				$order_id = Db::col('SELECT order_id FROM cart_orders WHERE order_nick = :order_nick', [
					':order_nick' => $order_nick
				]);
				if (!$order_id) return $this->fail('order_nick');
			}
			if ($order_id) $this->handler('Check the legality of the action');
		}
	},
	
	"active_id#" => function (&$order_id) {
		extract($this->gets(['user_id']), EXTR_REFS);
		$order_id = $user_id ? Cart::getActiveOrderId($user_id) : false;
		if (!$order_id) return $this->fail('CR004');
	},
	"active_id#create" => function (&$order_id) {
		extract($this->gets(['active_id#?','user_id', 'user', 'ans', 'lang', 'city_id','timezone']), EXTR_REFS);
		$order_id = $active_id;
		if (!$order_id) { //Заказа нет
			if (!$user) {
				$user = User::create($lang, $city_id, $timezone);
				if (!$user) return $this->fail('CR009');
				$ans['token'] = $user['user_id'] . '-' . $user['token'];
				$user_id = $user['user_id'];
			}
			$order_id = Cart::create($user_id);
			if (!$order_id) return $this->fail('CR008');
		}
	},
	'city' => function (&$city) {
		extract($this->gets(['city_id','lang']), EXTR_REFS);
		$city = City::getById($city_id, $lang);
	},
	'user' => function (&$user) {
		extract($this->gets(['token']), EXTR_REFS);
		$user = User::fromToken($token);
	},
	'user_id' => function (&$user_id) {
		extract($this->gets(['token']), EXTR_REFS);
		$user = User::fromToken($token);
		$user_id = $user['user_id'] ?? false;
	},
	'rule' => function (&$rule) {
		extract($this->gets(['order_id#']));
		$status = Db::col('SELECT status FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
		if (!$status || !isset($this->meta['rules'][$status])) return $this->fail('CR018');
		$rule = $this->meta['rules'][$status];
	},
	'basket' => function (&$basket) {
		extract($this->gets(['order_id#']));
		$basket = Db::all('SELECT position_id, discount, count from cart_basket where order_id = :order_id', [
			':order_id' => $order_id
		]);
	}
];