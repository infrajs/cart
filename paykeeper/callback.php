<?php

use infrajs\ans\Ans;
use infrajs\config\Config;
use infrajs\cart\Cart;

$ans = array();

$conf = Config::get('cart');
$conf = $conf['paykeeper'];

$secret_seed = $conf['secret'];
$paymentid = Ans::req('id');
$sum = Ans::req('sum');
$clientid = Ans::req('clientid'); //email
$orderid = Ans::req('orderid');
$key = Ans::req('key');

$mykey = md5($paymentid . number_format($sum, 2, ".", "") . $clientid . $orderid . $secret_seed);
if ($key != $mykey) return Ans::err($ans, 'Данные повреждены. Код PK001');
if (!$orderid) return Ans::err($ans, 'Нет информации о заказе. Код PK005');
if (!Cart::canI($orderid)) return Ans::err($ans, 'У вас нет доступа к заказу. Код PK003');

$order = Cart::loadOrder($orderid);
if (!$order) return Ans::err($ans, 'Заказ не найден. Код PK002');

$ogood = Cart::getGoodOrder($orderid);
if ($sum != $ogood['alltotal']) return Ans::err($ans, 'Ошибка с суммой заказа. Код PK004');

$info = $_POST;
$order['paykeeper']['info'] = $info;
$order['status'] = 'check';
Cart::saveOrder($order, $place);

echo "OK " . md5($paymentid . $secret_seed);
