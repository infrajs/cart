<?php
use infrajs\config\Config;
use infrajs\cart\Cart;
use infrajs\ans\Ans;
use infrajs\view\View;
use infrajs\cart\sbrfpay\Sbrfpay;

$ans = [];
$id = Ans::get('id');
if (!$id) return Ans::err($ans, 'Заказ не найден');
$ans['id'] = $id;
$place = Ans::get('place','string',['admin','orders']);
if (!$place) return Ans::err($ans, 'Не указано место работы с заказом');
$ans['place'] = $place;

$order = Cart::loadOrder($id);

if (!$order) return Ans::err($ans, 'Заказ не найден. Код 100');

if (empty($order['pay']['choice']) || $order['pay']['choice'] != 'Оплатить онлайн') return Ans::err($ans, 'Ошибка. Выбран несовместимый способ оплаты. Код 105');

if (!isset($_GET['orderId'])) {
	$status = Ans::get('status');
	if ($status) return Ans::err($ans, 'Ссылка устарела. Код 003');

	$ogood = Cart::getGoodOrder($id);
	
	if (!$ogood['alltotal']) return Ans::err($ans, 'Отсутствует стоиость заказа. Код 102');
	$ans['order'] = $order;

	if (isset($ogood['sbrfpay']['orderId'])) { //Если ссылка создана, то она не меняется
		//Нужно проверить статус, может уже всё оплачено
		$orderId = $ogood['sbrfpay']['orderId'];
		
		$info = Sbrfpay::getInfo($orderId);
		
		if ($info['orderStatus'] == 6) {
			//[actionCodeDescription] => Истек срок ожидания ввода данных.
			return Ans::err($ans, $info['actionCodeDescription']);
		} else if ($info['orderStatus'] == 2) { //Вся сумма авторизирована
			$order = Cart::loadOrder($id);
			$status = 'success';
			//Во всех остальных случаях пробуем ещё раз оплатить
			$order['status'] = 'check';
			Cart::saveOrder($order, $place);
			$ans['order'] = $order;
			$ans['msg'] = 'Заказ оплачен';
			return Cart::ret($ans, 'check');
		} 

		$ans['orderId'] = $ogood['sbrfpay']['orderId'];
		$ans['formUrl'] = $ogood['sbrfpay']['formUrl'];
	} else {
		$res = Sbrfpay::getId($id, $ogood['alltotal']);

		if (!empty($res['errorCode'])) return Ans::err($ans, $res['errorMessage']);
		
		$ans['orderId'] = $res['orderId'];
		$ans['formUrl'] = $res['formUrl'];	
		$order = Cart::loadOrder($id);
		$order['sbrfpay'] = [];
		$order['sbrfpay']['orderId'] = $ans['orderId'];
		$order['sbrfpay']['formUrl'] = $ans['formUrl'];
		Cart::saveOrder($order, $place);
		
		
	}
	$ans['order'] = $order;
	return Ans::ret($ans);
} else {
	$orderId = $_GET['orderId'];
	if (empty($orderId)) return Ans::err($ans, 'Ссылка устарела. Код 001');
	
	$status = Ans::get('status');
	if (empty($status) || !in_array($status, ['error','success'])) return Ans::err($ans, 'Ссылка устарела. Код 010');
	
	
	if (empty($order['sbrfpay']) || $order['sbrfpay']['orderId'] != $orderId) return Ans::err($ans, 'Ссылка устарела. Код 002');
	
	
	$info = Sbrfpay::getInfo($orderId);
	
	if ($info['orderStatus'] == 2) { //Вся сумма авторизирована
		//Оплачено и статус меняется
		$order['sbrfpay']['info'] = $info;
		$order['status'] = 'check';
		Cart::saveOrder($order, $place);
		$ans['order'] = $order;
		$ans['msg'] = 'Заказ оплачен';
		return Cart::ret($ans, 'check');
	} else {
		$order['sbrfpay']['info'] = $info;
		Cart::saveOrder($order, $place);
		$ans['order'] = $order;
		$add = isset($info['actionCodeDescription'])? $info['actionCodeDescription'] : '';
		return Ans::ret($ans, 'Ошибка, заказ не оплачен. '.$add);
	}
	

}

