<?php
use infrajs\rest\Rest;
use infrajs\catalog\Catalog;
use infrajs\excel\Xlsx;
use infrajs\ans\Ans;
use infrajs\access\Access;
use infrajs\path\Path;
use infrajs\user\User;
use infrajs\session\Session;

Access::debug(true);

return Rest::get( function(){
		echo 'Укажите в адресе действие';
	}, 'verify', [
		function () {
			echo 'Укажите в адресе email';
		}, function ($type, $email, $val = null) {
			$ans = array();
			$ans['email'] = $email;
			if (!User::checkData($email, 'email')) return Ans::err($ans, 'Некорректный email');
			
			
			
			if (is_null($val)) {
				$ans['verify'] = Session::getVerify($email);
				$ans['user'] = Session::getUser($email,true);
				return Ans::ret($ans,'Проверка статуса');
			}
			if ($val == '0') {
				Session::setVerify($email, null);
				$ans['user'] = Session::getUser($email,true);
				return Ans::ret($ans,'Верификация пользователя отменена');
			} else if ($val == '1') {
				Session::setVerify($email);
				$ans['user'] = Session::getUser($email,true);
				return Ans::ret($ans,'Пользователь верифицирован');
			} else if ($val == 'create') {
				$ans['user'] = Session::getUser($email,true);
				if (!$ans['user']) $ans['user'] = Session::createUser($email);
				return Ans::ret($ans,'Пользователь создан');
			}
			$ans['user'] = Session::getUser($email,true);
			return Ans::ret($ans,'Пользователь');
		}
	]
);