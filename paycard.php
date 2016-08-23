<?php
	// возвращаемые коды
	// 0 - нет прав доступа к странице
	// 1 - права есть
	
	@define('ROOT','../../../');
	require_once(ROOT.'infra/plugins/infra/infra.php');
	infra_require('*cart/cart.inc.php');
	$id=(int)$_GET['id'];
	$action=$_GET['action'];
	$ans=array('id'=>$id);
	$order=Cart::getGoodOrder($id);

	if(!$order)return infra_err($ans,'Заявка не найдена!');
	if(!cart_isMy($id))return infra_err($ans,'Заявки нет в списке ваших заявок!');
	if(!cart_canI($id,$action))return infra_err($ans,'С заявкой нельзя выполнить действие '.$action.'.');//действие paycard есть правда со ссылкой а не с обработкой
	
	$conf = Config::get('access');
	$email = $conf['email'];
	$conf = Config::get('cart');
	$p=explode(',',$email);
	$email=$p[0];
	
	if($action=='refunds'){
		if(!$order['manage']['bankpaid'])return infra_err($ans,'По заявке не было оплаты');
		$ans = array(
			"delivery"=>$order['manage']['deliverycost'],
			"total"=>$order['total'],//total включает manage.summary если есть, alltotal Включает и стоимость доставки если есть
			"id"=>$id,
			"rule"=>$order['rule'],
			"amount" => $order['total'],
			"currency" => "RUB",
			"orderNumber" => $id,
			"org_amount" => $order['alltotal'],
			"RRN" => $order['manage']['bankpaid']['RRN'],
			"INT_REF" => $order['manage']['bankpaid']['INT_REF'],
			"macData"=>'',
			"trType" => 22,
			"merchantTerminal" => $conf['terminal'],
			"backref" => $conf['backref'],
			"email" => $email,
			"timestamp" => gmdate("omdHis",time()),
			"nonce" => dechex(mt_rand(0x1000, 0xFFFFFFF)).dechex(mt_rand(0x1000, 0xFFFFFFF)).dechex(mt_rand(0x1000, 0xFFFFFFF)).dechex(mt_rand(0x1000, 0xFFFFFFF))
		);
		$toMacData = array(
			$ans["orderNumber"],
			$ans["amount"],
			$ans["currency"],
			$ans["org_amount"],
			$ans["RRN"],
			$ans["INT_REF"],
			$ans["trType"],
			$ans["merchantTerminal"],
			$ans["backref"],
			$ans["email"],
			$ans["timestamp"],
			$ans["nonce"]
		);
		foreach($toMacData as $data){
			$data=strval($data);
			if($data){
				$ans['macData'].=strlen($data).$data;
			}else{
				$ans['macData'].='-';
			}
		}
		$key = $conf['key'];
		$hmac = hash_hmac('sha1',$ans['macData'],pack('H*', $key));
		$ans['sign'] = strtoupper($hmac);
		$ans['bankurl'] = $conf['bankurl'];
		file_put_contents(ROOT.'infra/data/.lastbankref.json',infra_json_encode($ans));
		return infra_echo($ans,'',1);
	}elseif($action=='paycard'){
		if($order['manage']['bankpaid'])return infra_err($ans,'По заявке уже зафиксирована оплата');
		

		$descr = array();
		Each::foro($order['basket'],function($pos,$prodart) use(&$descr){
			$descr[]=$prodart.' - '.$pos['count'];
		});
		$descr=implode(',',$descr);
		
		

		$ans = array(
			"delivery"=>$order['manage']['deliverycost'],
			"total"=>$order['total'],//total включает manage.summary если есть, alltotal Включает и стоимость доставки если есть
			"id"=>$id,
			"rule"=>$order['rule'],
			"amount" => $order['alltotal'],
			"currency" => "RUB",
			"orderNumber" => $id,
			"description" => $descr,
			"merchantTerminal" => $conf['terminal'],
			"trType" => 1,
			"key" => $conf['key'],
			"macData" => "",
			"merchantName" => $conf['merch_name'],
			"merchant" => $conf['merchant'],
			"email" => $email,
			"timestamp" => gmdate("omdHis",time()),
			"nonce" => dechex(mt_rand(0x1000, 0xFFFFFFF)).dechex(mt_rand(0x1000, 0xFFFFFFF)).dechex(mt_rand(0x1000, 0xFFFFFFF)).dechex(mt_rand(0x1000, 0xFFFFFFF)),
			"backref" => $conf['backref'],
			"sign" => "",
			"lang" => "",
			"service" => ""
		);
		/*$ans = array(
			"amount" => '29',
			"currency" => "RUB",
			"orderNumber" => '20140728064447',
			"description" => 'Red Book',
			"merchantTerminal" => "79036768",
			"trType" => '1',
			"key" => "C50E41160302E0F5D6D59F1AA3925C45",
			"macData" => "",
			"merchantName" => $conf['merch_name'],
			"merchant" => "790367686219999",
			"email" => 'lakhtin@psbank.ru',
			"timestamp" => '20140728104402',
			"nonce" => 'F2B2DD7E603A7ADA',
			"backref" => "http://193.200.10.117:8080/pit/merchant_test_page_purchase.html",
			"sign" => "",
			"lang" => "",
			"service" => ""
		);*/
		$toMacData = array(
			$ans["amount"],
			$ans["currency"], 
			$ans["orderNumber"],
			$ans["merchantName"],
			$ans["merchant"],
			$ans["merchantTerminal"],
			$ans["email"],
			$ans["trType"],
			$ans["timestamp"],
			$ans["nonce"],
			$ans["backref"]
		);
		foreach($toMacData as $data){
			$data=strval($data);
			if($data){
				$ans['macData'].=strlen($data).$data;
			}else{
				$ans['macData'].='-';
			}
		}
		//AMOUNT,CURRENCY,ORDER,MERCH_NAME,MERCHANT,TERMINAL,EMAIL,TRTYPE,TIMESTAMP,NONCE,BACKREF
		
		$hmac = hash_hmac('sha1',$ans['macData'],pack('H*', $ans['key']));
		$ans['sign'] = strtoupper ($hmac);
		$ans['bankurl'] = $conf['bankurl'];
		file_put_contents(ROOT.'infra/data/.lastbankpay.json',infra_json_encode($ans));
		return infra_echo($ans,'',1);
	}

?>
