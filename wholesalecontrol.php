<?php
@define('ROOT','../../../');
require_once(ROOT.'infra/plugins/infra/infra.php');
infra_require('*cart/cart.inc.php');
infra_require('*session/session.php');


if(!infra_session_get('safe.manager'))return infra_err($ans, 'Нет доступа к этому действию');

$data=Load::loadJSON('*merchants.json');
$ans=array();

if($_REQUEST['change']){
	// Изменяем ценовой порог
	$data['level']=(int)$_REQUEST['level'];
	file_put_contents(ROOT.'infra/data/merchants.json', infra_json_encode($data));
	return infra_ret($ans,'Ценовой порог изменён.');
}elseif($_REQUEST['add']){
	// Добавляем пользователя
	$email=trim(strip_tags($_REQUEST['email']));
	$data['merchants'][$email]=array('name'=>trim(strip_tags($_REQUEST['name'])));
	file_put_contents(ROOT.'infra/data/merchants.json', infra_json_encode($data));
	return infra_ret($ans, 'Пользователь добавлен.');
}else{
	// получаем данные из конфига
	if(!isset($data['merchants']) || !$data['merchants']){
		return infra_ret($ans, 'Пока нет оптовых покупателей!');
	}
	return infra_ret($data);
}

?>