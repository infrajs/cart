<?php
namespace infrajs\cart;

use infrajs\ans\Ans;
use infrajs\user\User;
use infrajs\cart\Cart;

class Pay {
	public static function check(&$ans, &$order) {
		header('Cache-Control: no-store');
		$order_nick = Ans::get('order_nick');
		if (!$order_nick) return Ans::err($ans, 'Заказ не найден. Код PK103');

		$lang = Ans::REQ('lang', Cart::$conf['lang']['list'], Cart::$conf['lang']['def']);
		$token = Ans::REQS('token', 'string', '');
		$user = User::fromToken($token);
		if (!$user) return Ans::err($ans, 'Требуется авторизация. Код p'.__LINE__);
		if ($order_nick == 'active') $order = Cart::getActiveOrder($user['user_id']);
		else $order = Cart::getByNick($order_nick);
		$ans['order'] = $order;
		if (!$order) return Ans::err($ans, 'Заказ не найден. Код PK102');

		if ($order['pay'] != 'card') return Ans::err($ans, 'Ошибка. Выбран несовместимый способ оплаты. Код '.__LINE__);
		/*
		При нажатии на оплатить должны поменять статус на paykeeper (ожидает оплату) и только в этом статусе эта страница сработает
		*/
		//Перешли в корень страницы /order_nick/paykeeper/
		if ($order['status'] == 'check') return Ans::ret($ans, 'Заказ находится на проверке. Код PK105');
		if ($order['status'] != 'pay') return Ans::err($ans, 'Некорректный статус заказа. Код PK106');

		if (!$order['total']) return Ans::err($ans, 'Отсутствует стоимость заказа. Код PK107');
	}
}