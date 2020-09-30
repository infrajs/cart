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
		extract($this->gets(['order_id'], 'v'.__LINE__), EXTR_REFS);
		$order = Cart::getById($order_id);
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
		if (!$model) throw $this::fail('CR013', 'v'.__LINE__);
	},
	'order_id' => function (&$order_id, $pname) {
		
		extract($this->gets(['order_nick'], 'v'.__LINE__), EXTR_REFS);

		if ($order_nick == 'active') {
			$order_id = $this->get('active_id', 'v'.__LINE__);
		} else {
			$order_id = Db::col('SELECT order_id FROM cart_orders WHERE order_nick = :order_nick', [
				':order_nick' => $order_nick
			]);
			
			if (!$order_id) return $this->fail('order_nick', 'v'.__LINE__);	
		}
		$this->handler('Check the legality of the action', 'v'.__LINE__);
	},
	"active_id" => function (&$order_id) {
		extract($this->gets(['user_id','user','iscreateorder'], 'v'.__LINE__));

		$order_id = $user_id ? Cart::getActiveOrderId($user_id) : false;
		if (!$order_id) {
			//Заказа нет
			if (!$iscreateorder) return $this->fail('CR004', 'v'.__LINE__);
			extract($this->gets(['ans','lang','city_id','timezone'], 'v'.__LINE__));
			if (!$user) {
				$user = User::create($lang, $city_id, $timezone);
				if (!$user) return $this->fail('CR009', 'v'.__LINE__);
				$ans['token'] = $user['user_id'] . '-' . $user['token'];
			}
			$order_id = Cart::create($user_id);
			if (!$order_id) return $this->fail('CR008', 'v'.__LINE__);
		}
	},
	'city' => function (&$city) {
		extract($this->gets(['city_id','lang'], 'v'.__LINE__), EXTR_REFS);
		$city = City::getById($city_id, $lang);
	},
	'user' => function (&$user) {
		extract($this->gets(['token'], 'v'.__LINE__), EXTR_REFS);
		$user = User::fromToken($token);
	},
	'user_id' => function (&$user_id) {
		extract($this->gets(['token'], 'v'.__LINE__), EXTR_REFS);
		$user = User::fromToken($token);
		$user_id = $user['user_id'] ?? false;
	},
	
	'status' => function (&$status) {
		extract($this->gets(['order_id'], 'v'.__LINE__));
		$status = Db::col('SELECT status FROM cart_orders WHERE order_id = :order_id', [
			':order_id' => $order_id
		]);
	},		
	'rule' => function (&$rule) {
		extract($this->gets(['status'], 'v'.__LINE__));
		if (!$status || !isset($this->meta['rules'][$status])) return $this->fail('CR018', 'v'.__LINE__);
		$rule = $this->meta['rules'][$status];
	},
	'basket' => function (&$basket) {
		extract($this->gets(['order_id'], 'v'.__LINE__));
		$basket = Db::all('SELECT position_id, discount, count from cart_basket where order_id = :order_id', [
			':order_id' => $order_id
		]);
	}
];