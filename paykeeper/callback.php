<?php

use infrajs\ans\Ans;
use infrajs\config\Config;
use infrajs\cart\Cart;

$ans = array();
$info = $_POST;
$ans['info'] = $info;
$conf = Config::get('cart');
$conf = $conf['paykeeper'];


$secret = $conf['secret'];
$paymentid = Ans::req('id');
$sum = Ans::req('sum');
$clientid = Ans::req('clientid'); //email
$orderid = Ans::req('orderid');
$key = Ans::req('key');

$mykey = md5($paymentid . number_format($sum, 2, ".", "") . $clientid . $orderid . $secret);
if ($key != $mykey) return Ans::err($ans, 'Данные повреждены. Код PK001');
if (!$orderid) return Ans::err($ans, 'Нет информации о заказе. Код PK005');
if (!Cart::canI($orderid)) return Ans::err($ans, 'У вас нет доступа к заказу. Код PK003');

$order = Cart::loadOrder($orderid);
if (!$order) return Ans::err($ans, 'Заказ не найден. Код PK002');

$ogood = Cart::getGoodOrder($orderid);
if(empty($ogood['alltotal'])) return Ans::err($ans, 'Ошибка в стоимости заказа. Код PK007');
if (number_format($sum, 2,'.','') != number_format($amount, 2,'.','')) return Ans::err($ans, 'Ошибка с суммой заказа. Код PK004');

if(!isset($order['paykeeper'])) return Ans::err($ans, 'Ошибка инициации оплаты. Код PK006');
$order['paykeeper']['info'] = $info;
$order['status'] = 'check';
Cart::saveOrder($order, $place);

echo "OK " . md5($paymentid . $secret);
