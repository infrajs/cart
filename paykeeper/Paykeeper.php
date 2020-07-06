<?php

namespace infrajs\cart\paykeeper;

use infrajs\config\Config;
use infrajs\cart\Cart;
use infrajs\view\View;

class Paykeeper
{
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
			"pay_amount" => number_format($amount, 2,'.',''),
			"clientid" => $fio,
			"orderid" => $orderid . ' на ' . View::getHost(),
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
	public static function getInfo($orderId)
	{
		$conf = Config::get('cart');
		$conf = $conf['paykeeper'];

		# Логин и пароль любого пользователя личного кабинета
		$user = $conf['userName'];
		$password = $conf['password'];
		$server = $conf['server'];

		# параметры запроса
		$auth_header =  array(
			'Authorization: Basic ' . base64_encode("$user:$password")
		);
		$request_headers = array_merge(
			$auth_header,
			array("Content-type: application/x-www-form-urlencoded")
		);

		$context = stream_context_create(array(
			'http' => array(
				'method' => 'GET',
				'header' => $request_headers
			)
		));

		$src = "/info/payments/byid/";
		$res = json_decode(file_get_contents("http://$server" . $src . "?id=$orderId", FALSE, $context), TRUE);



		return $res;
	}
}
