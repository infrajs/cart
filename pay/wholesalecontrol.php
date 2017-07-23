<?php
use infrajs\cart\Cart;
use infrajs\nostore\Nostore;
use infrajs\router\Router;
use infrajs\ans\Ans;
use infrajs\each\Each;
use infrajs\load\Load;
use infrajs\access\Access;
use infrajs\session\Session;

if (!is_file('vendor/autoload.php')) {
	chdir('../../../');
	require_once('vendor/autoload.php');
	Router::init();
}


if(!Session::get('safe.manager'))return infra_err($ans, 'Нет доступа к этому действию');

$data=Load::loadJSON('~cart/merchants.json');
$ans=array();

if($_REQUEST['change']){
	// Изменяем ценовой порог
	$data['level']=(int)$_REQUEST['level'];
	file_put_contents('data/merchants.json', infra_json_encode($data));
	return infra_ret($ans,'Ценовой порог изменён.');
}elseif($_REQUEST['add']){
	// Добавляем пользователя
	$email = trim(strip_tags($_REQUEST['email']));
	$data['merchants'][$email]=array('name'=>trim(strip_tags($_REQUEST['name'])));
	file_put_contents('data/merchants.json', infra_json_encode($data));
	return infra_ret($ans, 'Пользователь добавлен.');
}else{
	// получаем данные из конфига
	if (!isset($data['merchants']) || !$data['merchants']) {
		return infra_ret($ans, 'Пока нет оптовых покупателей!');
	}
	return infra_ret($data);
}

?>