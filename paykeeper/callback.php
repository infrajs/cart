<?php

use infrajs\ans\Ans;
use infrajs\config\Config;
use infrajs\cart\Cart;
use infrajs\load\Load;

$ans = array();
$info = $_POST;

$conf = Config::get('cart');
$conf = $conf['paykeeper'];


$save = 'data/auto/.paykeepercallback.json';

//$info = Load::loadJSON($save);
//$_REQUEST = $info;

$json = json_encode($info, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
file_put_contents($save, $json);


$ans['info'] = $info;
$secret = $conf['secret'];
$paymentid = Ans::REQ('id');
$sum = Ans::REQ('sum');
$clientid = Ans::REQ('clientid'); //fio + (email)
$orderid = Ans::REQ('orderid');
$key = Ans::REQ('key');

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
