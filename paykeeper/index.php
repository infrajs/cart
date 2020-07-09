<?php
use infrajs\config\Config;
use infrajs\cart\Cart;
use infrajs\ans\Ans;
use infrajs\load\Load;
use infrajs\nostore\Nostore;
use infrajs\cart\paykeeper\Paykeeper;

Nostore::on();
$ans = [];
$orderid = Ans::get('id');
if (!$orderid) return Ans::err($ans, 'Заказ не найден. Код PK103');
$ans['id'] = $orderid;
$place = Ans::get('place','string',['admin','orders']);
if (!$place) return Ans::err($ans, 'Не указано место работы с заказом. Код ошибки PK101');
$ans['place'] = $place;

$order = Cart::loadOrder($orderid);
$ans['order'] = $order;
if (!$order) return Ans::err($ans, 'Заказ не найден. Код PK102');
//if (isset($order['paykeeper']['formUrl'])) return Ans::ret($ans);
$fields = Load::loadJSON('-cart/fields.json');
if (empty($order['pay'])) $order['pay'] = [];
if (empty($order['pay']['choice'])) $order['pay']['choice'] = $fields['paydefault'];
if ($order['pay']['choice'] != 'Оплатить онлайн') return Ans::err($ans, 'Ошибка. Выбран несовместимый способ оплаты. Код PK104');




//Перешли в корень страницы /orderid/paykeeper/
if ($order['status'] == 'check') return Ans::ret($ans, 'Заказ находится на проверке. Код PK105');
if ($order['status'] != 'paykeeper') return Ans::err($ans, 'Некорректный статус заказа. Код PK106');

$ogood = Cart::getGoodOrder($orderid);
if (!$ogood['alltotal']) return Ans::err($ans, 'Отсутствует стоимость заказа. Код PK107');

$link = Paykeeper::getLink($orderid, $ogood['alltotal'], $ogood['email'], $ogood['phone'], $ogood['name']);

if (!$link) return Ans::err($ans, 'Ошибка соединения. Код PK108');	
$order['paykeeper'] = [];
$order['paykeeper']['formUrl'] = $link;
Cart::saveOrder($order, $place);

$ans['order'] = $order;
return Ans::ret($ans);