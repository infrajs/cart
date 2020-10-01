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

$context->args = [
	"lang" => function (&$lang, $pname) {
		if (!in_array($$pname, Cart::$conf['lang']['list'])) {
			$lang = $this->lang;
			return $this->fail('required', $pname);
		}
	},
	"transport" => function ($transport, $pname) {
		if (!$$pname) return;
		if (!in_array($$pname, Cart::$conf['transports'])) return $this->fail('required', $pname);
	},
	"pay" => function ($pay, $pname){
		if (!$$pname) return;
		if (!in_array($pay, Cart::$conf['pays'])) return $this->fail('required', $pname);
	},
	"place" => function ($place, $pname) {
		if (!in_array($$pname, ['orders', 'admin'])) return $this->fail('required', $pname);
		if ($place != 'admin') return;
		$user = $this->get('user');
		if (empty($user['admin'])) return $this->fail('CR003');
	},
	"callback" => function ($callback, $pname) {
		if (!in_array($callback, ['yes', 'no', ''])) return $this->fail('required', $pname);
	},
	"city_id" => function (&$city_id, $pname) {
		$city_id = (int) Db::col('SELECT city_id FROM city_cities WHERE city_id = :city_id', [
			':city_id' => $city_id
		]);
		if (!$city_id) return $this->fail('CR059');
	},
	"item_num" => function (&$item_num, $pname) {
		if (!$item_num) $item_num = 1;
	},
	"start" => function (&$start) {
		if (!$start) $start = strtotime('first day of this month 0:0');
	},
	"statuses" => function (&$statuses) {
		$statuses = explode(',',$statuses);
		foreach ($statuses as $i => $status) {
			if (!in_array($status,['wait','complete','pay','check'])) continue;
			$statuses[$i] = trim($status);
		}
	},
	"position_ids" => function (&$position_ids) {
		extract($this->gets(['user_id']));
		$order_ids = Db::colAll('SELECT DISTINCT order_id FROM cart_basket where position_id in (' . implode(',', $position_ids) . ')');
		if (sizeof($order_ids) > 1) return $this->fail('position_ids');
		if (sizeof($order_ids) == 0) return $this->ret('position_ids');
		
		$order_id = $order_ids[0];
		if (!Cart::isOwner($order_id, $user_id)) return $this->fail('position_ids');
	},
	"callback" => function (&$callback) {
		if (!in_array($callback, ['yes', 'no', ''])) return $this->fail('callback');
	},
	"catkit" => function (&$catkit, $pname) {
		if (!$catkit) $catkit = '';
	},
	"article_nick" => function ($article_nick, $pname) {
		extract($this->gets(['catkit', 'item_num', 'producer_nick']));
		$pos = [
			'producer_nick' => $producer_nick,
			'article_nick' => $article_nick,
			'item_num' => $item_num,
			'catkit' => $catkit
		];
		$model = Cart::getFromShowcase($pos);
		if (!$model) return $this->fail('CR013');
		if (empty($model['Цена'])) return $this->fail('CR014');
	},
	"position_id" => function ($position_id, $pname) {
		extract($this->gets(['user_id']));
		$pos = Db::fetch('SELECT order_id, article_nick, producer_nick, item_num, catkit from cart_basket 
			where position_id = :position_id', [
			':position_id'=> $position_id
		]);
		if (!$pos) return $this->fail('CR013');
		$order_id = $pos['order_id'];
		if (!Cart::isOwner($order_id, $user_id)) return $this->fail('position_ids');
	},
	"pay" => function (&$pay) {
		if (!in_array($pay, Cart::$conf['pays'])) $pay = null;
	},
	"email" => function (&$email, $pname) {
		if (!Mail::check($email)) $email = '';
	},
	'token' => function (&$token, $pname) {
		extract($this->gets(['ans']), EXTR_REFS);
		$user = User::fromToken($token);
		$user_id = $user ? $user['user_id'] : false;		
		if (!$user) return;
		$ans['user'] = array_intersect_key($user, array_flip(['user_id','admin','email']));
		header('Cache-Control: no-store');
	},
	"order_nick" => function ($order_nick, $pname) {
		if ($order_nick == 'active') {
			$order_id = $this->get('active_id');
		} else {
			$order_id = Db::col('SELECT order_id FROM cart_orders WHERE order_nick = :order_nick', [
				':order_nick' => $order_nick
			]);
			if (!$order_id) return $this->fail('order_nick');	
		}
		$order_id = $this->get('order_id');
		
	},
	"order_id" => function (&$order_id, $pname) {
		if (!$order_id) {
			$order_id = $this->get('active_id');

		} else {
			$order_id = Db::col('SELECT order_id FROM cart_orders WHERE order_id = :order_id', [
				':order_id' => $order_id
			]);
			if (!$order_id) throw $this::fail('order_id');
		}

		$this->handler('Check the legality of the action');
	}
];