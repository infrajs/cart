<?php
	@define('ROOT','../../../');
	require_once(ROOT.'infra/plugins/infra/infra.php');
	infra_require('-cart/cart.inc.php');
	$ans=array();

	
	$ba=$_REQUEST; //banksAnswer
	$conf=infra_config();
	$key = $conf['cart']['key'];
	if(!isset($ba['RESULT'])){
		$bares=false;
	}else{
		$bares=(int)$ba['RESULT'];
	}
	$ans['ba']=$ba;

	if(!isset($ba['ORDER'])){
		$ans['msg']='Не указан ORDER';
		infra_mail_toSupport($_SERVER['HTTP_HOST'].' '.$ans['msg'],'noreplay@'.$_SERVER['HTTP_HOST'],print_r($ba,true));
		file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
		return infra_err($ans);
	}

	$order=Cart::loadOrder($ba['ORDER']);
	if(!$order){
		$ans['msg']='Заявка не найдена ORDER';
		infra_mail_toSupport($_SERVER['HTTP_HOST'].' '.$ans['msg'],'noreplay@'.$_SERVER['HTTP_HOST'],print_r($ba,true));
		file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
		return infra_err($ans);
	}

	if(!$order['manage']['lastbank'])$order['manage']['lastbank']=array();
	$order['manage']['lastbank'][]=$ba;
	cart_saveOrder($order,false);
	
	if(isset($ba['RESULT'])&&$ba['RESULT']==0){//нет ошибок
		if($ba['TRTYPE']==1){//Оплата
			//Проверки HMAC  ответа на запрос проведения оплаты товара:
			//AMOUNT,CURRENCY,ORDER,MERCH_NAME,MERCHANT,TERMINAL,EMAIL,TRTYPE,TIMESTAMP,NONCE,BACKREF, RESULT, RC, RCTEXT, AUTHCODE, RRN, INT_REF	
			$toHmac =  array(
				$ba['AMOUNT'],
				$ba['CURRENCY'],
				$ba['ORDER'],
				$ba['MERCH_NAME'],
				$ba['MERCHANT'],
				$ba['TERMINAL'],
				$ba['EMAIL'],
				$ba['TRTYPE'],
				$ba['TIMESTAMP'],
				$ba['NONCE'],
				$ba['BACKREF'],
				$ba['RESULT'],
				$ba['RC'],
				$ba['RCTEXT'],
				$ba['AUTHCODE'],
				$ba['RRN'],
				$ba['INT_REF']
			);
			//$str = print_r($toHmac, true);
			//$str .= print_r($_REQUEST, true);
			foreach($toHmac as $data){
				$data=strval($data);
				if($data!=""){
					$macData.=strlen($data).$data;
				}else{
					$macData.='-';
				}
			}
			$hmac =	strtoupper(hash_hmac('sha1',$macData,pack('H*', $key)));
			$bhmac = strtoupper($ba['P_SIGN']);
			//$str.= "\r\n".$hmac."\r\n".$bhmac."\r\n";
			

			if($hmac === $bhmac) {
				
				$order['manage']['bankpaid'] = $ba;//Эта инфа попадает в бразуер, но там уже собранные коды, ничего секретного нет.
				
				if($order['manage']['paid']){
					$order['msg']='У заявки уже была оплата '.$order['manage']['paid'];
					$order['status']='error';
				}elseif($order['alltotal']>$ba['AMOUNT']){
					$order['msg']='Оплачена другая сумма';
					infra_mail_toSupport($_SERVER['HTTP_HOST'].' '.$order['msg'],'noreplay@'.$_SERVER['HTTP_HOST'],print_r($ba,true).print_r($order,true));
					$order['status']='error';
				}else{
					$order['status']='paid';
				}

				$order['manage']['paid']=$ba['AMOUNT'];
				$order['manage']['paidtime']=time();
				$order['manage']['paidtype']='bank';
				
				cart_saveOrder($order,false);
				$ans['msg']='Всё ок';
				file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
				
				return cart_ret($order,'bankpaid');
			}else{
				$ans['msg']='Неорректный hmac: '.$hmac.', банк '.$bhmac;
				file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
				unset($ans['msg']);
				return infra_err($ans,'Аутентификация не пройдена');
			}
		}elseif($ba['TRTYPE']==22){//Отмена
			$toHmac =  array(
				$ba['ORDER'],
				$ba['AMOUNT'],
				$ba['CURRENCY'],
				$ba['ORG_AMOUNT'],
				$ba['RRN'],
				$ba['INT_REF'],
				$ba['TRTYPE'],
				$ba['TERMINAL'],
				$ba['BACKREF'],
				$ba['EMAIL'],
				$ba['TIMESTAMP'],
				$ba['NONCE'],
				$ba['RESULT'],
				$ba['RC'],
				$ba['RCTEXT']
			);
			foreach($toHmac as $data){
				$data=strval($data);
				if($data!=""){
					$macData.=strlen($data).$data;
				}else{
					$macData.='-';
				}
			}

			$hmac =	strtoupper(hash_hmac('sha1',$macData,pack('H*', $key)));
			$bhmac = strtoupper($ba['P_SIGN']);
			
			if($hmac === $bhmac) {
				
				if(!$order['manage']['paid']){
					$order['msg']='Возврат по заявки у которой нет отметки об оплате';
					$order['status']='error';
				}elseif($order['alltotal']!=$ba['AMOUNT']){
					infra_mail_toAdmin($_SERVER['HTTP_HOST'].' оплачена другая сумма','noreplay@'.$_SERVER['HTTP_HOST'],print_r($ba,true).print_r($order,true));
					$order['msg']='Возврат по другой сумме';
					$order['status']='error';
				}else{
					$order['manage']['bankrefused'] = $ba;//Эта инфа попадает в бразуер, но там уже собранные коды, ничего секретного нет.
					$order['status']='canceled';
				}

				cart_saveOrder($order,false);
				

				$ans['msg']='Всё ок';
				file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
				return cart_ret($order,'bankrefused');
			}else{

				$ans['msg']='Неорректный hmac: '.$hmac.', банк '.$bhmac;
				file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
				unset($ans['msg']);
				return infra_err($ans,'Аутентификация не пройдена');
			}

		}else{
			$ans['msg']='указанный TRTYPE не обрабатывается';
			file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
			return infra_err($ans);
		}
	}else{
		$ans['msg']='RESULT сообщает об ошибке';
		file_put_contents(ROOT.'infra/data/.lastbank.json',infra_json_encode($ans));
		return infra_err($ans);
	}