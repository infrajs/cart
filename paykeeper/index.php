<?php
use infrajs\config\Config;
use infrajs\cart\Cart;
use infrajs\ans\Ans;
use infrajs\load\Load;
use infrajs\db\Db;
use infrajs\nostore\Nostore;
use infrajs\cart\paykeeper\Paykeeper;
use infrajs\user\User;

header('Cache-Control: no-store');

$ans = [];
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
//if (isset($order['paykeeper']['formUrl'])) return Ans::ret($ans);

if ($order['pay'] != 'card') return Ans::err($ans, 'Ошибка. Выбран несовместимый способ оплаты. Код '.__LINE__);
/*
При нажатии на оплатить должны поменять статус на paykeeper (ожидает оплату) и только в этом статусе эта страница сработает
*/
//Перешли в корень страницы /order_nick/paykeeper/
if ($order['status'] == 'check') return Ans::ret($ans, 'Заказ находится на проверке. Код PK105');
if ($order['status'] != 'pay') return Ans::err($ans, 'Некорректный статус заказа. Код PK106');

if (!$order['total']) return Ans::err($ans, 'Отсутствует стоимость заказа. Код PK107');

$link = Paykeeper::getLink($order_nick, $order['total'], $order['email'], $order['phone'], $order['name']);
if (!$link) return Ans::err($ans, 'Ошибка соединения. Код PK108');

$ans['formURL'] = $link;
// $r = Db::exec('UPDATE cart_orders
// 	SET paydata = :paydata, dateedit = now()
// 	WHERE order_id = :order_id
// ', [
// 	':order_id' => $order['order_id'],
// 	':paydata' => json_encode($paydata, JSON_UNESCAPED_UNICODE)
// ]) !== false;

$ans['order'] = $order;
return Ans::ret($ans);