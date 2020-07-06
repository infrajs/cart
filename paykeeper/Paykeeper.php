<?php

namespace infrajs\cart\paykeeper;

use infrajs\config\Config;
use infrajs\cart\Cart;
use infrajs\load\Load;


class Paykeeper
{
	public static function err($ans, $msg) {
		$ans['msg'] = $msg;
		$ans['result'] = 0;
		
		$json = json_encode($ans, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
		$save = 'data/auto/.paykeeper-callback-error.json';
		file_put_contents($save, $json);

		return $ans;
	}
	public static function callback($info) {
		$ans = array();
		$conf = Config::get('cart');
		$conf = $conf['paykeeper'];
		$secret = $conf['secret'];
		
		//$info = Load::loadJSON('data/auto/.paykeepercallback.json');
		//$ans['info'] = $info;
		
		foreach(['id','sum','clientid','orderid','key'] as $k) {
			if(empty($info[$k])) return Paykeeper::err($ans, 'Недостаточно данных. Код PK008');
		}
		$paymentid = $info['id'];
		$sum = $info['sum'];
		$clientid = $info['clientid']; //fio + (email)
		$orderid = $info['orderid'];
		$key = $info['key'];

		$mykey = md5($paymentid . number_format($sum, 2, ".", "") . $clientid . $orderid . $secret);

		if ($key != $mykey) return Paykeeper::err($ans, 'Данные повреждены. Код PK001');
		if (!$orderid) return Paykeeper::err($ans, 'Нет информации о заказе. Код PK005');
		
		//Системный вызов, доступ не проверяем
		//if (!Cart::canI($orderid)) return Paykeeper::err($ans, 'У вас нет доступа к заказу. Код PK003');

		$order = Cart::loadOrder($orderid);
		if (!$order) return Paykeeper::err($ans, 'Заказ не найден. Код PK002');

		$ogood = Cart::getGoodOrder($orderid);
		if(empty($ogood['alltotal'])) return Paykeeper::err($ans, 'Ошибка в стоимости заказа. Код PK007');
		$amount = $ogood['alltotal'];
		if (number_format($sum, 2,'.','') != number_format($amount, 2,'.','')) return Paykeeper::err($ans, 'Ошибка с суммой заказа. Код PK004');

		if(!isset($order['paykeeper'])) return Paykeeper::err($ans, 'Ошибка инициации оплаты. Код PK006');
		$order['paykeeper']['info'] = $info;
		$order['status'] = 'check';
		$place = 'orders';
		Cart::saveOrder($order, $place);

		$ans['result'] = 1;
		$ans['msg'] = "OK " . md5($paymentid . $secret);
		return $ans;
	}
	public static function getLink($orderid, $amount, $email, $phone, $fio)
	{
		$conf = Config::get('cart');
		$conf = $conf['paykeeper'];


		# Логин и пароль от личного кабинета PayKeeper
		$user = $conf['userName'];
		$password = $conf['password'];
		$server = $conf['server'];

		# Basic-авторизация передаётся как base64
		$base64 = base64_encode("$user:$password");
		$headers = array();
		array_push($headers, 'Content-Type: application/x-www-form-urlencoded');
		# Подготавливаем заголовок для авторизации
		array_push($headers, 'Authorization: Basic ' . $base64);

		# Параметры платежа, сумма - обязательный параметр
		# Остальные параметры можно не задавать
		$payment_data = array(
			"pay_amount" => number_format($amount, 2, '.', ''),
			"clientid" => $fio . ' (' . $email . ')',
			"orderid" => $orderid,
			"client_email" => $email,
			"service_name" => "Заказ",
			"client_phone" => $phone
		);

		# Готовим первый запрос на получение токена безопасности
		$uri = "/info/settings/token/";

		# Для сетевых запросов в этом примере используется cURL
		$curl = curl_init();

		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_URL, $server . $uri);
		curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'GET');
		curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($curl, CURLOPT_HEADER, false);

		# Инициируем запрос к API
		$response = curl_exec($curl);
		$php_array = json_decode($response, true);

		# В ответе должно быть заполнено поле token, иначе - ошибка
		if (isset($php_array['token'])) $token = $php_array['token'];
		else return false;

		# Готовим запрос 3.4 JSON API на получение счёта
		$uri = "/change/invoice/preview/";

		# Формируем список POST параметров
		$request = http_build_query(array_merge($payment_data, array('token' => $token)));

		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_URL, $server . $uri);
		curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'POST');
		curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($curl, CURLOPT_HEADER, false);
		curl_setopt($curl, CURLOPT_POSTFIELDS, $request);


		$response = json_decode(curl_exec($curl), true);
		# В ответе должно быть поле invoice_id, иначе - ошибка
		if (isset($response['invoice_id'])) $invoice_id = $response['invoice_id'];
		else return false;

		# В этой переменной прямая ссылка на оплату с заданными параметрами
		$link = "http://$server/bill/$invoice_id/";

		# Теперь её можно использовать как угодно, например, выводим ссылку на оплату
		return $link;
	}
	// public static function getInfo($orderId)
	// {
	// 	$conf = Config::get('cart');
	// 	$conf = $conf['paykeeper'];

	// 	# Логин и пароль любого пользователя личного кабинета
	// 	$user = $conf['userName'];
	// 	$password = $conf['password'];
	// 	$server = $conf['server'];

	// 	# параметры запроса
	// 	$auth_header =  array(
	// 		'Authorization: Basic ' . base64_encode("$user:$password")
	// 	);
	// 	$request_headers = array_merge(
	// 		$auth_header,
	// 		array("Content-type: application/x-www-form-urlencoded")
	// 	);

	// 	$context = stream_context_create(array(
	// 		'http' => array(
	// 			'method' => 'GET',
	// 			'header' => $request_headers
	// 		)
	// 	));

	// 	$src = "/info/payments/byid/";
	// 	$res = json_decode(file_get_contents("http://$server" . $src . "?id=$orderId", FALSE, $context), TRUE);



	// 	return $res;
	// }
}
