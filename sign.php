<?php
	// возвращаемые коды
	// 0 - отобразить форму регистрации и сообщение
	// 1 - отобразить только сообщение

	@define('ROOT','../../../');
	require_once(ROOT.'infra/plugins/infra/infra.php');
	infra_require('*cart/cart.inc.php');
	$type=$_REQUEST['type'];
	$submit=$_REQUEST['submit'];

	$ans=array('msg'=>'','result'=>1,'type'=>$type);
	
	
	if($type=='up'){

		$email=infra_session_getEmail();
		$ans['email']=$email;
		if($email)return infra_ret($ans, 'Вы зарегистрированы и авторизованы!');
		if($submit){
			$email=trim(strip_tags($_REQUEST['email']));
			$ans['email']=$email;
			$password=$_REQUEST['password'];
			$msg=cart_checkReg($email,$password);
			if(is_string($msg))return infra_err($ans,$msg);
			return infra_ret($ans,'Вы успешно зарегистрировались, вам на {email} отправлено сообщение с данными для входа.');
		}else{
			return infra_ans($ans);
		}
	}elseif($type=='in'){
		//sleep(2);
		$email=infra_session_getEmail();
		$ans['email']=$email;
		if($email)return infra_ret($ans, 'Вход в систему произведён!');//С регистрацией нельзя зайти в новую

		if(!$submit)return infra_ret($ans);
		
		$email=trim(strip_tags($_REQUEST['email']));
		if(!$email)return infra_err($ans,"Введите email указанный при регистрации.");
		$is_email=preg_match('/^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$/',$email);
		if(!$is_email)return infra_err($ans,'Некорректный email.');
		$password=$_REQUEST['password'];
		if(!$password)return infra_err($ans,"Укажите пароль.");
		
		$user=infra_session_getUser($email);


		$session_id=$user['session_id'];
		$truePassword=$user['password'];
		if(!$session_id || $truePassword!=$password)return infra_err($ans,"Неверный email или пароль.");
		

		infra_session_change($session_id,md5($password));

		return infra_ret($ans,"Вы успешно авторизовались!");
		
	}elseif($_REQUEST['type']=='out'){
		$ans['email'] = infra_session_getEmail();
		if(!$ans['email'])return infra_ret($ans,'Вы успешно вышли из профиля!');
		return infra_ans($ans);
	}elseif($_REQUEST['type']=='resendpass'){
		$email = trim(strip_tags($_REQUEST['email']));
		if(!$submit)return infra_ans($ans);
		if(!$email)return infra_err($ans,'Укажите email');

		$is_email=preg_match('/^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9})$/',$email);
		if(!$is_email)return infra_err($ans,'Некорректный email');

		
		

		$data=infra_session_getUser($email);
		if(!$data)return infra_err($ans,'Пользователя с таким email не найдено.');		

		cart_mail('user',$email,'resendpass');

		return infra_ret($ans,'На почту отправлено сообщение с паролем.');
		
	}
?>