<?php
use infrajs\rest\Rest;
use infrajs\catalog\Catalog;
use infrajs\excel\Xlsx;
use infrajs\ans\Ans;
use infrajs\access\Access;
use infrajs\path\Path;
use infrajs\user\User;
use infrajs\session\Session;

Access::admin(true);

return Rest::get( function () {
	echo 'Укажите в адресе email';
}, function ($email, $val = null) {
	$ans = array();
	$ans['email'] = $email;
	if (!User::checkData($email, 'email')) return Ans::err($ans, 'Некорректный email');
	
	if (is_null($val)) {
		$ans['admin'] = Session::user_get($email, ['safe','manager']);
		return Ans::ret($ans,'Проверка статуса');
	}
	if ($val == '0') {
		Session::user_set($email, ['safe','manager']);
		return Ans::ret($ans,'Сброс прав менеджера');
	}

	Session::user_set($email, ['safe','manager'], 1);	
	return Ans::ret($ans,'Права менеджера установлены');
});